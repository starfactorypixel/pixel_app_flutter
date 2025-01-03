import 'package:collection/collection.dart';
import 'package:crclib/catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/data_source_package_exceptions.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

export 'package:pixel_app_flutter/domain/data_source/models/package/data_source_incoming_package.dart';
export 'package:pixel_app_flutter/domain/data_source/models/package/data_source_outgoing_package.dart';

abstract class DataSourcePackage extends UnmodifiableListView<int> {
  DataSourcePackage(super.source) {
    this
      ..checkHasEnoughBytes()
      ..checkValidStartingByte()
      ..checkValidEndingByte()
      ..checkValidCheckSum();
  }

  DataSourcePackage.fromBody(List<int> body)
      : super([
          startingByte,
          ...body,
          ...calculateCheckSum(body),
          endingByte,
        ]);

  static List<int> getBodyAndCheckSum({
    int firstConfigByte = 0x00,
    required int secondConfigByte,
    required int parameterId,
    required BytesConvertible convertible,
  }) {
    final data = convertible.toBytes;
    final body = <int>[
      firstConfigByte,
      secondConfigByte,
      ...parameterId.toBytesUint16,
      data.length,
      ...data,
    ];

    return [...body, ...calculateCheckSum(body)];
  }

  /// If [fixedBytesLength] is not null, then bytes length will be set to this
  /// value, and element count in returned list will be equal to
  /// [fixedBytesLength]
  static List<int> intToBytes(
    int? data, {
    int? fixedBytesLength,
  }) {
    if (data == null) {
      if (fixedBytesLength != null) {
        return List.filled(fixedBytesLength, 0);
      }
      return const [];
    }
    final bytesLength =
        fixedBytesLength ?? IntBytesLengthExtension.bytesLength(data);

    return data
        .toRadixString(16)
        .padLeft(bytesLength * 2, '0')
        .split('')
        .splitAfterIndexed((index, element) => index.isOdd)
        .map((e) => int.parse(e.join(), radix: 16))
        .toList();
  }

  Uint8List get toUint8List => Uint8List.fromList(this);

  static const startingByte = 0x3c;
  static const endingByte = 0x3e;

  // From 1(skipping starting byte),
  // to length - 3(-1 ending byte, - 2 checksum bytes))
  List<int> get body => sublist(1, length - 3);

  static List<int> calculateCheckSum(List<int> body) {
    return int.parse(Crc16Mcrf4xx().convert(body).toString()).toBytesUint16;
  }

  String get secondConfigByte {
    // Contains request type and direction flag
    final configByte = this[2];
    return configByte.toRadixString(2).padLeft(8, '0');
  }

  DataSourceRequestDirection get directionFlag {
    // 0 - device to MainECU, 1 - MainECU to Device
    return DataSourceRequestDirection.fromInt(int.parse(secondConfigByte[0]));
  }

  DataSourceRequestType get requestType {
    // request type is in the last 5 bits
    final last5bits = secondConfigByte.substring(3);
    try {
      return DataSourceRequestType.fromInt(int.parse(last5bits, radix: 2));
    } on Exception catch (_) {
      throw Exception('package $this');
    }
  }

  int get firstParameterIDByte => this[3];
  int get secondParameterIDByte => this[4];

  DataSourceParameterId get parameterId {
    return DataSourceParameterId.fromInt(
      [firstParameterIDByte, secondParameterIDByte].toIntFromUint16,
    );
  }

  int get dataLength => this[5];

  List<int> get data => sublist(6, 6 + dataLength);

  bool checkTypeAndDirectionIdentity({
    required int type,
    required int direction,
  }) {
    return type == requestType.value && directionFlag.value == direction;
  }

  @override
  String toString({bool withDirection = true}) {
    if (!withDirection) return toFormattedHexString;
    return '${directionFlag.name.capitalize}$toFormattedHex';
  }
}

extension PackageValidationExtension on List<int> {
  void checkHasEnoughBytes() {
    if (length < 9) {
      throw NotEnoughBytesDataSourcePackageException(length);
    }
  }

  void checkValidStartingByte() {
    // Check starting byte
    if (this[0] != DataSourcePackage.startingByte) {
      throw const InvalidStartingByteDataSourcePackageException();
    }
  }

  void checkValidEndingByte() {
    // Check ending byte
    if (this[length - 1] != DataSourcePackage.endingByte) {
      throw InvalidEndingByteDataSourcePackageException(this);
    }
  }

  void checkValidCheckSum() {
    final checkSum = sublist(length - 3, length - 1);
    final body = sublist(1, length - 3);
    final calculatedCheckSum = DataSourcePackage.calculateCheckSum(body);
    if (!const DeepCollectionEquality().equals(checkSum, calculatedCheckSum)) {
      throw WrongCheckSumDataSourcePackageException(
        packageCheckSum: checkSum,
        calculatedCheckSum: calculatedCheckSum,
        body: body,
        package: this,
      );
    }
  }
}
