import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

enum DataSourceProtocolVersion {
  subscription('subscription'),
  periodicRequests('periodicRequests');

  const DataSourceProtocolVersion(this.name);

  final String name;

  static DataSourceProtocolVersion fromString(String name) {
    return DataSourceProtocolVersion.values
        .firstWhere((element) => element.name == name);
  }

  R when<R>({
    required R Function() subscription,
    required R Function() periodicRequests,
  }) {
    switch (this) {
      case DataSourceProtocolVersion.periodicRequests:
        return periodicRequests();
      case DataSourceProtocolVersion.subscription:
        return subscription();
    }
  }
}

@immutable
class DeveloperToolsParameters {
  const DeveloperToolsParameters({
    required this.protocolVersion,
    required this.requestsPeriodInMillis,
    required this.subscriptionParameterIds,
    required this.enableRandomErrorGenerationForDemoDataSource,
    required this.enableHandshakeResponse,
    required this.handshakeResponseTimeoutInMillis,
  });

  factory DeveloperToolsParameters.fromMap(Map<String, dynamic> map) {
    return DeveloperToolsParameters(
      protocolVersion: DataSourceProtocolVersion.fromString(
        map['protocolVersion'] as String,
      ),
      requestsPeriodInMillis: map['requestsPeriodInMillis'] as int,
      subscriptionParameterIds:
          (map['subscriptionParameterIds'] as List).cast<int>().toSet(),
      enableRandomErrorGenerationForDemoDataSource:
          map['enableRandomErrorGenerationForDemoDataSource'] as bool,
      enableHandshakeResponse: map['enableHandshakeResponse'] as bool,
      handshakeResponseTimeoutInMillis:
          map['handshakeResponseTimeoutInMillis'] as int,
    );
  }

  const DeveloperToolsParameters.defaultValues()
      : enableRandomErrorGenerationForDemoDataSource = false,
        protocolVersion = DataSourceProtocolVersion.subscription,
        requestsPeriodInMillis = 1500,
        enableHandshakeResponse = true,
        handshakeResponseTimeoutInMillis = 0,
        subscriptionParameterIds = const {};

  final DataSourceProtocolVersion protocolVersion;

  final int requestsPeriodInMillis;

  final Set<int> subscriptionParameterIds;

  final bool enableRandomErrorGenerationForDemoDataSource;

  final bool enableHandshakeResponse;

  final int handshakeResponseTimeoutInMillis;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'protocolVersion': protocolVersion.name,
      'requestsPeriodInMillis': requestsPeriodInMillis,
      'subscriptionParameterIds': subscriptionParameterIds.toList(),
      'enableRandomErrorGenerationForDemoDataSource':
          enableRandomErrorGenerationForDemoDataSource,
      'enableHandshakeResponse': enableHandshakeResponse,
      'handshakeResponseTimeoutInMillis': handshakeResponseTimeoutInMillis,
    };
  }

  @override
  int get hashCode => Object.hash(
        protocolVersion,
        requestsPeriodInMillis,
        subscriptionParameterIds,
        enableRandomErrorGenerationForDemoDataSource,
        enableHandshakeResponse,
        handshakeResponseTimeoutInMillis,
      );

  @override
  bool operator ==(Object other) {
    return other is DeveloperToolsParameters &&
        other.protocolVersion == protocolVersion &&
        other.requestsPeriodInMillis == requestsPeriodInMillis &&
        const DeepCollectionEquality.unordered()
            .equals(other.subscriptionParameterIds, subscriptionParameterIds) &&
        other.enableRandomErrorGenerationForDemoDataSource ==
            enableRandomErrorGenerationForDemoDataSource &&
        other.enableHandshakeResponse == enableHandshakeResponse &&
        other.handshakeResponseTimeoutInMillis ==
            handshakeResponseTimeoutInMillis;
  }

  @override
  String toString() {
    return 'DeveloperToolsParameters(protocolVersion: $protocolVersion, '
        'requestsPeriodInMillis: $requestsPeriodInMillis, '
        'subscriptionParameterIds: $subscriptionParameterIds, '
        'enableRandomErrorGenerationForDemoDataSource: '
        '$enableRandomErrorGenerationForDemoDataSource, '
        'enableHandshakeResponse: $enableHandshakeResponse, '
        'handshakeResponseTimeoutInMillis: $handshakeResponseTimeoutInMillis)';
  }

  DeveloperToolsParameters copyWith({
    DataSourceProtocolVersion? protocolVersion,
    int? requestsPeriodInMillis,
    Set<int>? subscriptionParameterIds,
    bool? enableRandomErrorGenerationForDemoDataSource,
    bool? enableHandshakeResponse,
    int? handshakeResponseTimeoutInMillis,
  }) {
    return DeveloperToolsParameters(
      protocolVersion: protocolVersion ?? this.protocolVersion,
      requestsPeriodInMillis:
          requestsPeriodInMillis ?? this.requestsPeriodInMillis,
      subscriptionParameterIds:
          subscriptionParameterIds ?? this.subscriptionParameterIds,
      enableRandomErrorGenerationForDemoDataSource:
          enableRandomErrorGenerationForDemoDataSource ??
              this.enableRandomErrorGenerationForDemoDataSource,
      enableHandshakeResponse:
          enableHandshakeResponse ?? this.enableHandshakeResponse,
      handshakeResponseTimeoutInMillis: handshakeResponseTimeoutInMillis ??
          this.handshakeResponseTimeoutInMillis,
    );
  }
}
