import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/bytes_convertible.dart';
import 'package:re_seedwork/re_seedwork.dart';

typedef ListUsbPortsCallback = List<String> Function();

class SerialPort {
  static List<String> get availablePorts => <String>[];
}

final class USBDataSource extends DataSource {
  // ignore: avoid_unused_constructor_parameters
  USBDataSource({required ListUsbPortsCallback getAvailablePorts})
      : super(key: kKey);

  static String kKey = 'stub';

  @override
  void addObserver(Observer observer) {}

  @override
  Future<Result<CancelDeviceDiscoveringError, void>> cancelDeviceDiscovering() {
    throw UnimplementedError();
  }

  @override
  Future<Result<ConnectError, void>> connect(String address) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DisconnectError, void>> disconnect() {
    throw UnimplementedError();
  }

  @override
  Future<Result<EnableError, void>> enable() {
    throw UnimplementedError();
  }

  @override
  Future<Result<GetDeviceListError, Stream<List<DataSourceDevice>>>>
      getDevicesStream() {
    throw UnimplementedError();
  }

  @override
  Future<bool> get isAvailable => throw UnimplementedError();

  @override
  Future<bool> get isEnabled => throw UnimplementedError();

  @override
  void observe(Observerable<dynamic> observable) {}

  @override
  Stream<DataSourceIncomingPackage<BytesConvertible>> get packageStream =>
      throw UnimplementedError();

  @override
  void removeObserver(Observer observer) {}

  @override
  Future<Result<SendPackageError, void>> sendPackage(
    DataSourceOutgoingPackage package,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Result<SendPackageError, void>> sendPackages(
    List<DataSourceOutgoingPackage> packages,
  ) {
    throw UnimplementedError();
  }
}
