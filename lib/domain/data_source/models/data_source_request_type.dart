sealed class DataSourceRequestType {
  const DataSourceRequestType(this.value);

  const factory DataSourceRequestType.mirror() = _MirrorDataSourceRequestType;
  const factory DataSourceRequestType.bufferRequest() =
      _BufferRequestDataSourceRequestType;
  const factory DataSourceRequestType.canRequest() =
      _CanRequestDataSourceRequestType;
  const factory DataSourceRequestType.handshake() =
      _HandshakeDataSourceRequestType;
  const factory DataSourceRequestType.subscription() =
      _SubscriptionDataSourceRequestType;
  const factory DataSourceRequestType.event() = _EventDataSourceRequestType;
  const factory DataSourceRequestType.unknown(int value) =
      _UnknownDataSourceRequestType;

  final int value;

  static const List<DataSourceRequestType> values = [
    DataSourceRequestType.mirror(),
    DataSourceRequestType.bufferRequest(),
    DataSourceRequestType.canRequest(),
    DataSourceRequestType.handshake(),
    DataSourceRequestType.subscription(),
    DataSourceRequestType.event(),
  ];

  static DataSourceRequestType fromInt(int value) {
    return DataSourceRequestType.values.firstWhere(
      (element) => element.value == value,
      orElse: () => _UnknownDataSourceRequestType(value),
    );
  }

  R maybeWhen<R>({
    required R Function() orElse,
    R Function()? mirror,
    R Function()? bufferRequest,
    R Function()? canRequest,
    R Function()? handshake,
    R Function()? subscription,
    R Function()? event,
    R Function(int value)? unknown,
  }) {
    return switch (this) {
      _MirrorDataSourceRequestType() => mirror?.call() ?? orElse(),
      _BufferRequestDataSourceRequestType() =>
        bufferRequest?.call() ?? orElse(),
      _CanRequestDataSourceRequestType() => canRequest?.call() ?? orElse(),
      _HandshakeDataSourceRequestType() => handshake?.call() ?? orElse(),
      _SubscriptionDataSourceRequestType() => subscription?.call() ?? orElse(),
      _EventDataSourceRequestType() => event?.call() ?? orElse(),
      _UnknownDataSourceRequestType(value: final int value) =>
        unknown?.call(value) ?? orElse(),
    };
  }

  bool get isSubscription => this is _SubscriptionDataSourceRequestType;
  bool get isEvent => this is _EventDataSourceRequestType;
  bool get isHandshake => this is _HandshakeDataSourceRequestType;
  bool get isBufferRequest => this is _BufferRequestDataSourceRequestType;
}

final class _MirrorDataSourceRequestType extends DataSourceRequestType {
  const _MirrorDataSourceRequestType() : super(0x00);
}

final class _BufferRequestDataSourceRequestType extends DataSourceRequestType {
  const _BufferRequestDataSourceRequestType() : super(0x01);
}

final class _CanRequestDataSourceRequestType extends DataSourceRequestType {
  const _CanRequestDataSourceRequestType() : super(0x02);
}

final class _HandshakeDataSourceRequestType extends DataSourceRequestType {
  const _HandshakeDataSourceRequestType() : super(0x10);
}

final class _SubscriptionDataSourceRequestType extends DataSourceRequestType {
  const _SubscriptionDataSourceRequestType() : super(0x11);
}

final class _EventDataSourceRequestType extends DataSourceRequestType {
  const _EventDataSourceRequestType() : super(0x15);
}

final class _UnknownDataSourceRequestType extends DataSourceRequestType {
  const _UnknownDataSourceRequestType(super.value);
}
