import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class SuspensionMode with EquatableMixin {
  const SuspensionMode({required this.id});

  const factory SuspensionMode.low() = _LowSuspensionMode;
  const factory SuspensionMode.highway() = _HighwaySuspensionMode;
  const factory SuspensionMode.offRoad() = _OffRoadSuspensionMode;
  const factory SuspensionMode.manual({required int value}) =
      _ManualSuspensionMode;
  const factory SuspensionMode.manualMiddle() = _ManualSuspensionMode.middle;

  factory SuspensionMode.fromId(int id) {
    return values.firstWhere((element) => element.id == id);
  }

  static const List<SuspensionMode> values = [
    SuspensionMode.low(),
    SuspensionMode.highway(),
    SuspensionMode.offRoad(),
    SuspensionMode.manualMiddle(),
  ];

  final int id;

  static const kMaxManualValue = 255;

  bool get isManual => this is _ManualSuspensionMode;

  static SuspensionMode get random => values[Random().nextInt(values.length)];

  T when<T>({
    required T Function() low,
    required T Function() highway,
    required T Function() offRoad,
    required T Function(int value) manual,
  }) {
    return switch (this) {
      _LowSuspensionMode() => low(),
      _HighwaySuspensionMode() => highway(),
      _OffRoadSuspensionMode() => offRoad(),
      _ManualSuspensionMode(value: final int value) => manual(value),
    };
  }

  T maybeWhen<T>({
    required T Function() orElse,
    T Function()? low,
    T Function()? highway,
    T Function()? offRoad,
    T Function(int value)? manual,
  }) {
    return switch (this) {
      _LowSuspensionMode() => low?.call() ?? orElse(),
      _HighwaySuspensionMode() => highway?.call() ?? orElse(),
      _OffRoadSuspensionMode() => offRoad?.call() ?? orElse(),
      _ManualSuspensionMode(value: final int value) =>
        manual?.call(value) ?? orElse(),
    };
  }

  @override
  List<Object?> get props => [id];
}

final class _LowSuspensionMode extends SuspensionMode {
  const _LowSuspensionMode() : super(id: 1);
}

final class _HighwaySuspensionMode extends SuspensionMode {
  const _HighwaySuspensionMode() : super(id: 2);
}

final class _OffRoadSuspensionMode extends SuspensionMode {
  const _OffRoadSuspensionMode() : super(id: 4);
}

final class _ManualSuspensionMode extends SuspensionMode {
  const _ManualSuspensionMode({required this.value})
      : assert(
          value >= 0 && SuspensionMode.kMaxManualValue <= 255,
          'Must be Uint8',
        ),
        super(id: kId);

  const _ManualSuspensionMode.middle()
      : value = 128,
        super(id: kId);

  static const kId = 128;

  final int value;

  @override
  List<Object?> get props => [
        ...super.props,
        value,
      ];
}
