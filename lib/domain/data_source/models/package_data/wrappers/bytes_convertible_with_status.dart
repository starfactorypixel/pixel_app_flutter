import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

abstract class BytesConvertibleWithStatus
    with EquatableMixin
    implements BytesConvertible {
  const BytesConvertibleWithStatus({required this.status});

  BytesConvertibleWithStatus.fromId(int id)
      : status = PeriodicValueStatus.fromId(id);

  const BytesConvertibleWithStatus.normal()
      : status = PeriodicValueStatus.normal;

  final PeriodicValueStatus status;

  @override
  List<int> get toBytes => bytesConverter.toBytes(this);

  @override
  List<Object?> get props => [status];
}

abstract class IntBytesConvertibleWithStatus
    extends BytesConvertibleWithStatus {
  const IntBytesConvertibleWithStatus({
    required this.value,
    required super.status,
  });

  IntBytesConvertibleWithStatus.fromId({
    required int id,
    required this.value,
  }) : super.fromId(id);

  const IntBytesConvertibleWithStatus.normal(this.value) : super.normal();

  final int value;

  @override
  List<Object?> get props => [...super.props, value];
}

class Uint8WithStatusBytesConverter<T extends IntBytesConvertibleWithStatus>
    extends BytesConverter<T> {
  const Uint8WithStatusBytesConverter(this.builder);

  @protected
  final T Function(int functionId, int value) builder;
  @override
  T fromBytes(List<int> bytes) {
    return builder(bytes[0], bytes[1]);
  }

  @override
  List<int> toBytes(T model) {
    return [
      ...model.status.toBytes,
      ...model.value.toBytesUint8,
    ];
  }
}

class Int16WithStatusBytesConverter<T extends IntBytesConvertibleWithStatus>
    extends BytesConverter<T> {
  const Int16WithStatusBytesConverter(this.builder);

  @protected
  final T Function(int functionId, int value) builder;

  @override
  T fromBytes(List<int> bytes) {
    return builder(bytes[0], bytes.sublist(1).toIntFromInt16);
  }

  @override
  List<int> toBytes(T model) {
    return [
      ...model.status.toBytes,
      ...model.value.toBytesInt16,
    ];
  }
}

class Uint16WithStatusBytesConverter<T extends IntBytesConvertibleWithStatus>
    extends BytesConverter<T> {
  const Uint16WithStatusBytesConverter(this.builder);

  @protected
  final T Function(int functionId, int value) builder;

  @override
  T fromBytes(List<int> bytes) {
    return builder(bytes[0], bytes.sublist(1).toIntFromUint16);
  }

  @override
  List<int> toBytes(T model) {
    return [
      ...model.status.toBytes,
      ...model.value.toBytesUint16,
    ];
  }
}

class Uint32WithStatusBytesConverter<T extends IntBytesConvertibleWithStatus>
    extends BytesConverter<T> {
  const Uint32WithStatusBytesConverter(this.builder);

  @protected
  final T Function(int functionId, int value) builder;

  @override
  T fromBytes(List<int> bytes) {
    return builder(bytes[0], bytes.sublist(1, 5).toIntFromUint32);
  }

  @override
  List<int> toBytes(T model) {
    return [
      ...model.status.toBytes,
      ...model.value.toBytesUint32,
    ];
  }
}

class Int32WithStatusBytesConverter<T extends IntBytesConvertibleWithStatus>
    extends BytesConverter<T> {
  const Int32WithStatusBytesConverter(this.builder);

  @protected
  final T Function(int functionId, int value) builder;

  @override
  T fromBytes(List<int> bytes) {
    return builder(bytes[0], bytes.sublist(1, 5).toIntFromInt32);
  }

  @override
  List<int> toBytes(T model) {
    return [
      ...model.status.toBytes,
      ...model.value.toBytesInt32,
    ];
  }
}
