import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:re_seedwork/re_seedwork.dart';

class OutgoingPackagesCubit extends Cubit<DeveloperToolsParameters>
    with ConsumerBlocMixin {
  OutgoingPackagesCubit({
    required this.dataSource,
    required this.developerToolsParametersStorage,
  })  : subscribeToParameterIdList = {},
        super(
          developerToolsParametersStorage.read().when(
                error: (e) => developerToolsParametersStorage.defaultValue,
                value: (v) => v,
              ),
        ) {
    subscribe<DeveloperToolsParameters>(
      developerToolsParametersStorage,
      _onDeveloperToolsParametersUpdated,
    );
  }

  bool subscribeTo(Set<DataSourceParameterId> parameterIds) {
    final newParameters = parameterIds.difference(subscribeToParameterIdList);
    if (newParameters.isEmpty) return false;
    subscribeToParameterIdList.addAll(parameterIds);

    state.protocolVersion.when(
      subscription: () => _subscribeTo(newParameters),
      periodicRequests: () => _setNewTimer(
        state.requestsPeriodInMillis,
        subscribeToParameterIdList,
      ),
    );

    emit(
      state.copyWith(
        subscriptionParameterIds:
            subscribeToParameterIdList.map((e) => e.value).toSet(),
      ),
    );
    return true;
  }

  void _subscribeTo(Set<DataSourceParameterId> parameterIds) {
    for (final parameterId in parameterIds) {
      final package = OutgoingSubscribePackage(parameterId: parameterId);
      sendPackage(package);
    }
  }

  void unsubscribeFrom(Set<DataSourceParameterId> parameterIds) {
    subscribeToParameterIdList.removeWhere(parameterIds.contains);

    state.protocolVersion.when(
      subscription: () => _unsubscribeFrom(parameterIds),
      periodicRequests: () => _setNewTimer(
        state.requestsPeriodInMillis,
        subscribeToParameterIdList,
      ),
    );

    emit(
      state.copyWith(
        subscriptionParameterIds:
            subscribeToParameterIdList.map((e) => e.value).toSet(),
      ),
    );
  }

  void _unsubscribeFrom(Set<DataSourceParameterId> parameterIds) {
    for (final parameterId in parameterIds) {
      final package = OutgoingUnsubscribePackage(parameterId: parameterId);
      sendPackage(package);
    }
  }

  void getValue(DataSourceParameterId id) {
    final package = OutgoingValueRequestPackage(parameterId: id);
    sendPackage(package);
  }

  void getValues(List<DataSourceParameterId> ids) {
    for (final id in ids) {
      final package = OutgoingValueRequestPackage(parameterId: id);
      sendPackage(package);
    }
  }

  void sendPackage(DataSourceOutgoingPackage package) {
    dataSource.sendPackage(package);
  }

  void _cancelTimer() {
    periodicRequestsTimer?.cancel();
    periodicRequestsTimer = null;
  }

  void _setNewTimer(int requestPeriod, Set<DataSourceParameterId> ids) {
    _cancelTimer();
    periodicRequestsTimer = Timer.periodic(
      Duration(milliseconds: requestPeriod),
      (timer) {
        for (final id in ids) {
          getValue(id);
        }
      },
    );
    final newIdList = [...ids];
    subscribeToParameterIdList
      ..clear()
      ..addAll(newIdList);
  }

  void _onDeveloperToolsParametersUpdated(DeveloperToolsParameters newParams) {
    if (newParams == state) return;
    final newRequestPeriod = newParams.requestsPeriodInMillis;
    final newSubscribeToParams = newParams.subscriptionParameterIds
        .map(DataSourceParameterId.fromInt)
        .toSet();
    if (newParams.protocolVersion != state.protocolVersion) {
      newParams.protocolVersion.when(
        subscription: () {
          _cancelTimer();
          _subscribeTo(newSubscribeToParams);
        },
        periodicRequests: () {
          _unsubscribeFrom(subscribeToParameterIdList);
          _setNewTimer(newRequestPeriod, newSubscribeToParams);
        },
      );
    } else if (newParams.requestsPeriodInMillis !=
        state.requestsPeriodInMillis) {
      _setNewTimer(newRequestPeriod, subscribeToParameterIdList);
    } else if (!const DeepCollectionEquality.unordered().equals(
      newParams.subscriptionParameterIds,
      subscribeToParameterIdList,
    )) {
      state.protocolVersion.when(
        subscription: () {
          _unsubscribeFrom(subscribeToParameterIdList);
          _subscribeTo(newSubscribeToParams);
        },
        periodicRequests: () {
          _setNewTimer(newRequestPeriod, newSubscribeToParams);
        },
      );
    }

    emit(newParams);
  }

  @visibleForTesting
  late final Set<DataSourceParameterId> subscribeToParameterIdList;

  @visibleForTesting
  Timer? periodicRequestsTimer;

  @protected
  final DataSource dataSource;

  @protected
  final DeveloperToolsParametersStorage developerToolsParametersStorage;

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
