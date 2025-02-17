import 'dart:math' show Random;

enum MotorGear {
  reverse(0x02),
  neutral(0x00),
  drive(0x01),
  low(0x04),
  boost(0x08),
  unknown(0xFF);

  const MotorGear(this.id);
  final int id;

  static MotorGear fromId(int id) {
    return MotorGear.values.firstWhere(
      (element) => element.id == id,
      orElse: () => MotorGear.unknown,
    );
  }

  R when<R>({
    required R Function() reverse,
    required R Function() neutral,
    required R Function() drive,
    required R Function() low,
    required R Function() boost,
    required R Function() unknown,
  }) {
    return switch (this) {
      MotorGear.reverse => reverse(),
      MotorGear.neutral => neutral(),
      MotorGear.drive => drive(),
      MotorGear.low => low(),
      MotorGear.boost => boost(),
      MotorGear.unknown => unknown(),
    };
  }

  static MotorGear get random => values[Random().nextInt(values.length)];
}
