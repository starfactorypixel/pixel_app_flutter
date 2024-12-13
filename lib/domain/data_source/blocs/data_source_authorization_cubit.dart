import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/authorizartion.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

part 'data_source_authorization_cubit.freezed.dart';

@freezed
class DataSourceAuthorizationState with _$DataSourceAuthorizationState {
  const DataSourceAuthorizationState._();

  const factory DataSourceAuthorizationState.initial() = _Initial;
  const factory DataSourceAuthorizationState.noDataSource() = _NoDataSource;
  const factory DataSourceAuthorizationState.failure() = _Failure;
  const factory DataSourceAuthorizationState.sendingInitializationRequest() =
      _SendingInitializationRequest;
  const factory DataSourceAuthorizationState.initializationTimeout() =
      _InitializationTimeout;
  const factory DataSourceAuthorizationState.initializationResponseReceived() =
      _InitializationResponseReceived;
  const factory DataSourceAuthorizationState.noSerialNumber({
    required DataSourceWithAddress dswa,
    required String deviceId,
  }) = _NoSerialNumber;
  const factory DataSourceAuthorizationState.sendingAuthorizationRequest() =
      _SendingAuthorizationRequest;
  const factory DataSourceAuthorizationState.authorizationTimeout() =
      _AuthorizationTimeout;
  const factory DataSourceAuthorizationState.authorized() = _Authorized;
  const factory DataSourceAuthorizationState.errorSavingSerialNumber() =
      _ErrorSavingSerialNumber;

  bool get isLoading => maybeWhen(
        sendingAuthorizationRequest: () => true,
        sendingInitializationRequest: () => true,
        initializationResponseReceived: () => true,
        initial: () => false,
        orElse: () => false,
      );
  bool get isFailure => maybeWhen(
        failure: () => true,
        authorizationTimeout: () => true,
        initializationTimeout: () => true,
        orElse: () => false,
      );
}

class DataSourceAuthorizationCubit extends Cubit<DataSourceAuthorizationState> {
  DataSourceAuthorizationCubit({
    required this.dataSourceStorage,
    required this.serialNumberStorage,
    required this.shouldWriteDataSourceCallback,
    this.initializationTimeout = kInitializationTimeout,
    this.authorizationTimeout = kAuthorizationTimeout,
  }) : super(const DataSourceAuthorizationState.initial());

  @visibleForTesting
  static const kInitializationTimeout = Duration(seconds: 2);

  @visibleForTesting
  static const kAuthorizationTimeout = Duration(seconds: 2);

  @protected
  final DataSourceStorage dataSourceStorage;

  @protected
  final Duration initializationTimeout;

  @protected
  final Duration authorizationTimeout;

  @protected
  final Future<bool> Function() shouldWriteDataSourceCallback;

  @protected
  final SerialNumberStorage serialNumberStorage;

  @visibleForTesting
  StreamSubscription<void>? eventsSubscription;

  Future<void> requestAuthorization(DataSourceWithAddress dswa) async {
    emit(const DataSourceAuthorizationState.sendingInitializationRequest());

    await eventsSubscription?.cancel();
    eventsSubscription = null;
    final ds = dswa.dataSource;
    eventsSubscription = ds.packageStream.listen(
      (package) => _onNewIncomingDataSourcePackage(package, dswa),
    );
    await ds.sendPackage(OutgoingAuthorizationInitializationRequestPackage());
    await Future<void>.delayed(initializationTimeout).then((value) {
      if (isClosed) return;
      state.maybeWhen(
        sendingInitializationRequest: () {
          ds.disconnectAndDispose();
          emit(const DataSourceAuthorizationState.initializationTimeout());
        },
        failure: ds.disconnectAndDispose,
        orElse: () {},
      );
    });
  }

  void _onNewIncomingDataSourcePackage(
    DataSourceIncomingPackage<BytesConvertible> package,
    DataSourceWithAddress dswa,
  ) {
    package
      ..voidOnModel<AuthorizationInitializationResponse,
          AuthorizationInitializationResponseIncomingDataSourcePackage>(
        (model) => _onAuthorizationInitializationResponse(
          model,
          dswa,
        ),
      )
      ..voidOnModel<AuthorizationResponse,
          AuthorizationResponseIncomingDataSourcePackage>((model) {
        if (model.success) {
          emit(const DataSourceAuthorizationState.authorized());
          return;
        }
        emit(const DataSourceAuthorizationState.failure());
      });
  }

  Future<void> _onAuthorizationInitializationResponse(
    AuthorizationInitializationResponse model,
    DataSourceWithAddress dswa,
  ) async {
    final id = model.deviceId.join();
    emit(const DataSourceAuthorizationState.initializationResponseReceived());
    if (model.method != 0x01) {
      emit(const DataSourceAuthorizationState.failure());
      await dswa.dataSource.disconnectAndDispose();
      throw UnimplementedError('Unknown authorization method: ${model.method}');
    }

    try {
      final response = await serialNumberStorage.read(id);

      if (isClosed) return;
      response.when(
        error: (e) {
          emit(const DataSourceAuthorizationState.failure());
          dswa.dataSource.disconnectAndDispose();
          Future<void>.error(e);
        },
        value: (value) {
          value.when(
            undefined: () {
              emit(
                DataSourceAuthorizationState.noSerialNumber(
                  dswa: dswa,
                  deviceId: id,
                ),
              );
            },
            presented: (chain) {
              authorize(
                dswa: dswa,
                chain: chain,
              );
            },
          );
        },
      );
    } catch (e) {
      emit(const DataSourceAuthorizationState.failure());
      await dswa.dataSource.disconnectAndDispose();

      rethrow;
    }
  }

  Future<void> authorize({
    required DataSourceWithAddress dswa,
    required SerialNumberChain chain,
  }) async {
    emit(const DataSourceAuthorizationState.sendingAuthorizationRequest());

    final package = OutgoingAuthorizationRequestPackage(
      request: AuthorizationRequest(sn: chain.sn),
    );
    await dswa.dataSource.sendPackage(package);

    final newState = await stream
        .where((event) => event is _Authorized || event is _Failure)
        .first
        .timeout(
      authorizationTimeout,
      onTimeout: () {
        return const DataSourceAuthorizationState.authorizationTimeout();
      },
    );

    emit(newState);

    if (newState is _Authorized && await shouldWriteDataSourceCallback()) {
      await dataSourceStorage.write(dswa);
      final result = await serialNumberStorage.write(chain);

      result.when(
        error: (error) {
          emit(const DataSourceAuthorizationState.errorSavingSerialNumber());
          Future<void>.error(error);
        },
        value: (value) {},
      );
    } else {
      await dswa.dataSource.disconnectAndDispose();
    }
  }

  @override
  Future<void> close() {
    eventsSubscription?.cancel();
    eventsSubscription = null;
    return super.close();
  }
}

extension on DataSource {
  Future<void> disconnectAndDispose() async {
    await disconnect();
    await dispose();
  }
}
