import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';

@immutable
class DataSourceWithAddress {
  const DataSourceWithAddress({
    required this.dataSource,
    required this.address,
  });

  final DataSource dataSource;

  final String address;

  @override
  int get hashCode => Object.hash(dataSource.hashCode, address.hashCode);

  @override
  bool operator ==(Object other) {
    return other is DataSourceWithAddress &&
        other.address == address &&
        other.dataSource == dataSource;
  }
}
