import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/implementations/uint16_with_status_body.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/empty_body.dart';

mixin DefaultEmptyBodyConverterMixin on DataSourceIncomingPackage<EmptyBody> {
  @override
  BytesConverter<EmptyBody> get bytesConverter =>
      const DefaultEmptyBodyConverter();
}

mixin SetUint8ResultBodyBytesConverterMixin
    on DataSourceIncomingPackage<SetUint8ResultBody> {
  @override
  BytesConverter<SetUint8ResultBody> get bytesConverter =>
      const SetUint8ResultBodyConverter();
}

mixin SuccessEventUint8BodyBytesConverterMixin
    on DataSourceIncomingPackage<SuccessEventUint8Body> {
  @override
  BytesConverter<SuccessEventUint8Body> get bytesConverter =>
      const SuccessEventUint8BodyConverter();
}

mixin Uint8WithStatusBodyBytesConverterMixin
    on DataSourceIncomingPackage<Uint8WithStatusBody> {
  @override
  BytesConverter<Uint8WithStatusBody> get bytesConverter =>
      Uint8WithStatusBody.converter;
}

mixin Uint32WithStatusBodyBytesConverterMixin
    on DataSourceIncomingPackage<Uint32WithStatusBody> {
  @override
  BytesConverter<Uint32WithStatusBody> get bytesConverter =>
      Uint32WithStatusBody.converter;
}

mixin Int16WithStatusBodyBytesConverterMixin
    on DataSourceIncomingPackage<Int16WithStatusBody> {
  @override
  BytesConverter<Int16WithStatusBody> get bytesConverter =>
      Int16WithStatusBody.converter;
}

mixin UInt16WithStatusBodyBytesConverterMixin
    on DataSourceIncomingPackage<UInt16WithStatusBody> {
  @override
  BytesConverter<UInt16WithStatusBody> get bytesConverter =>
      UInt16WithStatusBody.converter;
}

mixin TwoUint16WithStatusBodyBytesConverterMixin
    on DataSourceIncomingPackage<TwoUint16WithStatusBody> {
  @override
  BytesConverter<TwoUint16WithStatusBody> get bytesConverter =>
      TwoUint16WithStatusBody.converter;
}

mixin TwoInt16WithStatusBodyBytesConverterMixin
    on DataSourceIncomingPackage<TwoInt16WithStatusBody> {
  @override
  BytesConverter<TwoInt16WithStatusBody> get bytesConverter =>
      TwoInt16WithStatusBody.converter;
}
