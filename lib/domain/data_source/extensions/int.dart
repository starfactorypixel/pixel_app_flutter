import 'dart:typed_data';

extension ToBytesExtension on int {
  Int8List get toBytesInt8 => intToBytesInt8(this);

  Uint8List get toBytesUint8 {
    final data = ByteData(Uint8List.bytesPerElement)..setUint8(0, this);
    return data.buffer.asUint8List();
  }

  Int8List get toBytesInt16 => intToBytesInt16(this);

  Uint8List get toBytesUint16 => intToBytesUint16(this);

  Int8List get toBytesInt32 {
    final data = ByteData(Int32List.bytesPerElement)
      ..setInt32(0, this, Endian.little);
    return data.buffer.asInt8List();
  }

  Uint8List get toBytesUint32 {
    final data = ByteData(Uint32List.bytesPerElement)
      ..setUint32(0, this, Endian.little);
    return data.buffer.asUint8List();
  }
}

Uint8List intToBytesUint16(int value, {Endian endian = Endian.little}) {
  final data = ByteData(Uint16List.bytesPerElement)
    ..setUint16(0, value, endian);
  return data.buffer.asUint8List();
}

Int8List intToBytesInt16(int value, {Endian endian = Endian.little}) {
  final data = ByteData(Int16List.bytesPerElement)..setInt16(0, value, endian);
  return data.buffer.asInt8List();
}

Int8List intToBytesInt8(int value) {
  final data = ByteData(Int8List.bytesPerElement)..setInt8(0, value);
  return data.buffer.asInt8List();
}

int uint32ToInt(List<int> bytes, {Endian endian = Endian.little}) {
  return Uint8List.fromList(bytes).buffer.asByteData().getUint32(0, endian);
}

int int32ToInt(List<int> bytes, {Endian endian = Endian.little}) {
  return Int8List.fromList(bytes).buffer.asByteData().getInt32(0, endian);
}

extension AsIntBytesExtension on List<int> {
  int get toIntFromInt8 {
    return Int8List.fromList(this).buffer.asByteData().getInt8(0);
  }

  int get toIntFromUint8 {
    return Uint8List.fromList(this).buffer.asByteData().getUint8(0);
  }

  int get toIntFromInt16 {
    return Int8List.fromList(this)
        .buffer
        .asByteData()
        .getInt16(0, Endian.little);
  }

  int get toIntFromUint16 {
    return Uint8List.fromList(this)
        .buffer
        .asByteData()
        .getUint16(0, Endian.little);
  }

  int get toIntFromInt32 => int32ToInt(this);

  int get toIntFromUint32 => uint32ToInt(this);
}

extension FromMilliExtension on int {
  double get fromMilli => this / 1000;
}

extension ParseListOfIntsExtension on String {
  List<int>? parseListOfInts() {
    return replaceAll(' ', '')
        .replaceAll(',', ' ')
        .split(' ')
        .map((e) => int.tryParse(e.trim()))
        .nonNulls
        .toList();
  }

  bool get hasUnparsedSegments {
    return replaceAll(' ', '')
        .replaceAll(',', ' ')
        .split(' ')
        .map((e) => int.tryParse(e.trim()))
        .where((element) => element == null)
        .isNotEmpty;
  }
}

extension FormattedHexExtension on int {
  String get toFormattedHex {
    final bytesLength = IntBytesLengthExtension.bytesLength(this);

    return '0x${toRadixString(16).padLeft(bytesLength * 2, '0').toUpperCase()}';
  }
}

extension FormattedHexListExtension on List<int> {
  Iterable<String> get toFormattedHex => map((e) => e.toFormattedHex);

  String get toFormattedHexString => '[${toFormattedHex.join(' ')}]';
}

extension IntBytesLengthExtension on int? {
  static int bytesLength(int? data) {
    if (data == null) return 0;
    final bits = (data.bitLength / 8).ceil();
    return bits.clamp(1, 100);
  }
}
