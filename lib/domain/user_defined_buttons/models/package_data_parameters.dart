import 'dart:typed_data' as td show Endian;
import 'dart:typed_data';

import 'package:re_seedwork/re_seedwork.dart';

sealed class DataBytesRange {
  const DataBytesRange(this.key);

  final String key;

  bool get endianMatters;

  static DataBytesRange fromString(String string) {
    if (string == AllDataBytesRange.kKey) return const AllDataBytesRange();
    final split = string.split('_');
    if (split[0] == ManualDataBytesRange.kKey) {
      final range = split[1].split('-');
      return ManualDataBytesRange(
        start: int.parse(range[0]),
        end: int.parse(range[1]),
      );
    }

    throw Exception('Unknown data bytes range string format: "$string"');
  }

  String get stringify;

  R when<R>({
    required R Function(AllDataBytesRange range) all,
    required R Function(ManualDataBytesRange range) manual,
  }) {
    return switch (this) {
      (final AllDataBytesRange r) => all(r),
      (final ManualDataBytesRange r) => manual(r),
    };
  }

  List<int> getRange(List<int> data);
}

final class AllDataBytesRange extends DataBytesRange {
  const AllDataBytesRange() : super(kKey);

  static const kKey = 'all';

  @override
  List<int> getRange(List<int> data) => data;

  @override
  bool get endianMatters => true;

  @override
  String get stringify => kKey;

  @override
  String toString() => 'AllDataBytesRange()';
}

final class ManualDataBytesRange extends DataBytesRange {
  const ManualDataBytesRange({
    required this.start,
    required this.end,
    this.maxRange = kMaxRange,
  })  : assert(end > start, '"end" index should be bigger than "start" index'),
        super(kKey);

  const ManualDataBytesRange.first({this.maxRange = kMaxRange})
      : start = 0,
        end = 1,
        super(kKey);

  static const kKey = 'manual';

  static const kMaxRange = 8;

  final int start;
  final int end;
  final int maxRange;

  int get length => end - start;

  ManualDataBytesRange get incrementStart {
    if (start + 1 >= end) return this;
    return ManualDataBytesRange(start: start + 1, end: end);
  }

  ManualDataBytesRange get incrementEnd {
    if (end - start + 1 > maxRange) return this;
    return ManualDataBytesRange(start: start, end: end + 1);
  }

  ManualDataBytesRange get decrementStart {
    if (start - 1 < 0) return this;
    if (end - start + 1 > maxRange) return this;
    return ManualDataBytesRange(start: start - 1, end: end);
  }

  ManualDataBytesRange get decrementEnd {
    if (end - 1 <= start) return this;
    return ManualDataBytesRange(start: start, end: end - 1);
  }

  @override
  List<int> getRange(List<int> data) {
    if (data.isEmpty) return [];
    if (start > data.length - 1) return [];
    if (end > data.length) return [];
    return data.sublist(start, end);
  }

  @override
  bool get endianMatters => end - start > 1;

  @override
  String get stringify => '${kKey}_$start-$end';

  @override
  String toString() => 'ManualDataBytesRange(start: $start, end: $end)';
}

enum Endian {
  big,
  little;

  static Endian fromString(String id) {
    return Endian.values.firstWhere((element) => element.name == id);
  }

  R when<R>({
    required R Function() big,
    required R Function() little,
  }) {
    return switch (this) {
      Endian.big => big(),
      Endian.little => little(),
    };
  }

  td.Endian get toTypedData {
    return when(
      big: () => td.Endian.big,
      little: () => td.Endian.little,
    );
  }
}

enum Sign {
  signed,
  unsigned;

  static Sign fromString(String id) {
    return Sign.values.firstWhere((element) => element.name == id);
  }

  R when<R>({
    required R Function() signed,
    required R Function() unsigned,
  }) {
    return switch (this) {
      Sign.signed => signed(),
      Sign.unsigned => unsigned(),
    };
  }
}

class PackageDataParameters {
  const PackageDataParameters({
    required this.endian,
    required this.range,
    required this.sign,
  });

  const PackageDataParameters.initial()
      : endian = Endian.little,
        range = const AllDataBytesRange(),
        sign = Sign.unsigned;

  factory PackageDataParameters.fromMap(Map<String, dynamic> map) {
    return PackageDataParameters(
      endian: map.parseAndMap('endian', Endian.fromString),
      range: map.parseAndMap('range', DataBytesRange.fromString),
      sign: map.parseAndMap('sign', Sign.fromString),
    );
  }

  final Endian endian;

  final DataBytesRange range;

  final Sign sign;

  int? getInt(List<int> data) {
    try {
      final bytes = range.getRange(data)..toEvenBytes(endian, sign);

      if (bytes.isEmpty) return null;
      final tdEndian = endian.toTypedData;

      final bytesCount = bytes.length.clamp(1, 8);

      return sign.when(
        signed: () {
          final byteData = Int8List.fromList(bytes).buffer.asByteData();

          return switch (bytesCount) {
            1 => byteData.getInt8(0),
            2 => byteData.getInt16(0, tdEndian),
            4 => byteData.getInt32(0, tdEndian),
            8 => byteData.getInt64(0, tdEndian),
            _ => null,
          };
        },
        unsigned: () {
          final byteData = Uint8List.fromList(bytes).buffer.asByteData();

          return switch (bytesCount) {
            1 => byteData.getUint8(0),
            2 => byteData.getUint16(0, tdEndian),
            4 => byteData.getUint32(0, tdEndian),
            8 => byteData.getUint64(0, tdEndian),
            _ => null,
          };
        },
      );
    } catch (e, s) {
      Future<void>.error(e, s);
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'endian': endian.name,
      'range': range.stringify,
      'sign': sign.name,
    };
  }

  PackageDataParameters copyWith({
    Sign? sign,
    Endian? endian,
    DataBytesRange? range,
  }) {
    return PackageDataParameters(
      sign: sign ?? this.sign,
      range: range ?? this.range,
      endian: endian ?? this.endian,
    );
  }
}

extension on List<int> {
  void toEvenBytes(Endian endian, Sign sign) {
    final lastBytePlaceholder = sign.when<int>(
      signed: () {
        final mostSignificant = endian.when(
          big: () => first,
          little: () => last,
        );
        final isNegative = (mostSignificant.toSigned(8) >> 7 & 1) == 1;
        return isNegative ? 0xFF : 0;
      },
      unsigned: () => 0,
    );

    switch (length) {
      case 3:
        endian.when(
          big: () => insert(0, lastBytePlaceholder),
          little: () => add(lastBytePlaceholder),
        );
      case > 4 && < 8:
        final bytes = List.generate(8 - length, (index) => lastBytePlaceholder);
        endian.when(
          big: () => insertAll(0, bytes),
          little: () => addAll(bytes),
        );
    }
  }
}
