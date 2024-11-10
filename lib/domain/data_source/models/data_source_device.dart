import 'package:meta/meta.dart';

@immutable
class DataSourceDevice {
  const DataSourceDevice({
    this.name,
    required this.address,
    this.isBonded = false,
  });

  final String? name;
  final String address;
  final bool isBonded;

  @override
  bool operator ==(Object other) {
    return other is DataSourceDevice &&
        name == other.name &&
        address == other.address &&
        isBonded == other.isBonded;
  }

  @override
  int get hashCode => Object.hash(name, address, isBonded);
}
