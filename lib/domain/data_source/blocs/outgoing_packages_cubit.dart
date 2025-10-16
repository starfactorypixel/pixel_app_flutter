import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
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

  static const MAX_PARAMETERS_LEN_PER_REQUEST = 32;

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

  static const TIMER_REQUEST_DELAY = 5000;

  void unsubscribeFromTimer() {
    periodicRequestsSubscriptionTimer?.cancel();
    periodicRequestsSubscriptionTimer = null;
  }

  void subscribeToTimer({required Set<DataSourceParameterId> parameterIds}) {
    unsubscribeFromTimer();

    periodicRequestsSubscriptionTimer = Timer.periodic(
      const Duration(milliseconds: TIMER_REQUEST_DELAY),
      (timer) {
        for (final id in parameterIds) {
          getValue(id);
        }
      },
    );
  }

  void sendDataSubscription({
    required Set<DataSourceParameterId> parameterIds,
    required bool isSubscribe,
  }) {
    if (isSubscribe) {
      subscribeTo(parameterIds);
    } else {
      unsubscribeFrom(parameterIds);
    }
  }

  void _subscribeTo(Set<DataSourceParameterId> parameterIds) {
    if (parameterIds.length > MAX_PARAMETERS_LEN_PER_REQUEST) {
      final items = parameterIds.slices(MAX_PARAMETERS_LEN_PER_REQUEST).toSet();
      for (final item in items) {
        _subscribeTo(item.toSet());
      }
      return;
    }

    final data =
        parameterIds.map((item) => item.value.toBytesUint16).flattenedToList;

    final package = DataSourceOutgoingPackage.raw(
      requestType: const DataSourceRequestType.subscriptionArray().value,
      parameterId: 0,
      data: data,
    );
    sendPackage(package);
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
    if (parameterIds.length > MAX_PARAMETERS_LEN_PER_REQUEST) {
      final items = parameterIds.slices(MAX_PARAMETERS_LEN_PER_REQUEST).toSet();
      for (final item in items) {
        _unsubscribeFrom(item.toSet());
      }
      return;
    }

    final data = parameterIds
        .map(
          (item) =>
              OutgoingUnsubscribePackage.modifyId(item).value.toBytesUint16,
        )
        .flattenedToList;

    final package = DataSourceOutgoingPackage.raw(
      requestType: const DataSourceRequestType.subscriptionArray().value,
      parameterId: 0,
      data: data,
    );
    sendPackage(package);
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

  @visibleForTesting
  Timer? periodicRequestsSubscriptionTimer;

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
