import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

mixin BatteryIndexMixin<T extends BytesConvertible>
    on DataSourceIncomingPackage<T> {
  @nonVirtual
  int get batteryIndex {
    final index = batteryIndexImpl;
    if (index != null) return index;
    throw Exception('Invalid battery index');
  }

  @visibleForOverriding
  int? get batteryIndexImpl;
}
