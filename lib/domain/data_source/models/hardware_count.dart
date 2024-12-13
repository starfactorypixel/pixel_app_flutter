import 'package:equatable/equatable.dart';
import 'package:re_seedwork/re_seedwork.dart';

final class HardwareCount with EquatableMixin {
  const HardwareCount({
    required this.motors,
    required this.batteries,
    required this.batteryCells,
    required this.temperatureSensors,
  });

  factory HardwareCount.all(int count) {
    return HardwareCount(
      motors: count,
      batteries: count,
      batteryCells: count,
      temperatureSensors: count,
    );
  }

  factory HardwareCount.fromMap(Map<String, dynamic> map) {
    return HardwareCount(
      motors: map.parse('motors'),
      batteries: map.parse('batteries'),
      batteryCells: map.parse('batteryCells'),
      temperatureSensors: map.parse('temperatureSensors'),
    );
  }

  final int motors;
  final int batteries;
  final int batteryCells;
  final int temperatureSensors;

  Map<String, int> toMap() {
    return {
      'motors': motors,
      'batteries': batteries,
      'batteryCells': batteryCells,
      'temperatureSensors': temperatureSensors,
    };
  }

  @override
  List<Object?> get props => [
        motors,
        batteries,
        batteryCells,
        temperatureSensors,
      ];
}
