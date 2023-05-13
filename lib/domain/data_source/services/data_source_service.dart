import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:re_seedwork/re_seedwork.dart';

typedef Observer = void Function(
  List<int>? raw,
  DataSourceIncomingPackage? parsed,
  DataSourceRequestDirection direction,
);

abstract class DataSource {
  DataSource({required this.id});

  final int id;

  void addObserver(Observer observer);

  void removeObserver(Observer observer);

  void observe(
    List<int>? raw,
    DataSourceIncomingPackage? parsed,
    DataSourceRequestDirection direction,
  );

  String get key;

  Stream<DataSourceIncomingPackage> get packageStream;

  Future<Result<SendPackageError, void>> sendPackage(
    DataSourceOutgoingPackage package,
  );

  Future<Result<SendPackageError, void>> sendPackages(
    List<DataSourceOutgoingPackage> packages,
  );

  Future<bool> get isEnabled;

  Future<bool> get isAvailable;

  Future<Result<EnableError, void>> enable();

  Future<Result<ConnectError, void>> connect(String address);

  Future<Result<DisconnectError, void>> disconnect();

  Future<Result<GetDeviceListError, Stream<List<DataSourceDevice>>>>
      getDevicesStream();

  Future<Result<CancelDeviceDiscoveringError, void>> cancelDeviceDiscovering();

  @mustCallSuper
  Future<void> dispose() async {}
}

enum SendPackageError { unknown, noConnection }

enum ConnectError { unknown, bondingError, unableToSubscribe }

enum DisconnectError { unknown }

enum GetDeviceListError { unknown }

enum CancelDeviceDiscoveringError { unknown }

enum EnableError {
  unknown,
  isAlreadyEnabled,
  isUnavailable,
  unsuccessfulEnableAttempt;

  R when<R>({
    required R Function() unknown,
    required R Function() isAlreadyEnabled,
    required R Function() isUnavailable,
    required R Function() unsuccessfulEnableAttempt,
  }) {
    switch (this) {
      case EnableError.unknown:
        return unknown();
      case EnableError.isAlreadyEnabled:
        return isAlreadyEnabled();
      case EnableError.isUnavailable:
        return isUnavailable();
      case EnableError.unsuccessfulEnableAttempt:
        return unsuccessfulEnableAttempt();
    }
  }
}
