import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

class OutgoingAuthorizationRequestPackage extends DataSourceOutgoingPackage {
  OutgoingAuthorizationRequestPackage({
    required AuthorizationRequest request,
  }) : super(
          requestType: const DataSourceRequestType.handshake(),
          parameterId: const DataSourceParameterId.authorization(),
          bytesConvertible: request,
        );
}

class OutgoingAuthorizationInitializationRequestPackage
    extends DataSourceOutgoingPackage {
  OutgoingAuthorizationInitializationRequestPackage()
      : super(
          requestType: const DataSourceRequestType.handshake(),
          parameterId: const DataSourceParameterId.authorization(),
          bytesConvertible: const AuthorizationInitializationRequest(),
        );
}
