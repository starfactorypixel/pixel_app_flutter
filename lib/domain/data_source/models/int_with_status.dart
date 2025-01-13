import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';
import 'package:re_seedwork/re_seedwork.dart';

@immutable
final class IntWithStatus {
  const IntWithStatus({
    required this.value,
    required this.status,
  });

  const IntWithStatus.initial()
      : value = 0,
        status = PeriodicValueStatus.normal;

  factory IntWithStatus.fromMap(Map<String, dynamic> map) {
    return IntWithStatus(
      value: map.parse('value'),
      status: PeriodicValueStatus.fromId(map.parse('status')),
    );
  }

  factory IntWithStatus.fromBytesConvertible(
    IntBytesConvertibleWithStatus bytesConvertible, [
    int? customValue,
  ]) {
    return IntWithStatus(
      value: customValue ?? bytesConvertible.value,
      status: bytesConvertible.status,
    );
  }

  final int value;
  final PeriodicValueStatus status;

  IntWithStatus copyWith({
    int? value,
    PeriodicValueStatus? status,
  }) {
    return IntWithStatus(
      value: value ?? this.value,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'status': status.id,
    };
  }
}
