import 'dart:math' show Random;

enum MotorRollDirection {
  stop(0x00),
  forward(0x01),
  reverse(0x02),
  unknown(0xFF);

  const MotorRollDirection(this.id);
  final int id;

  static MotorRollDirection fromId(int id) {
    return MotorRollDirection.values.firstWhere(
      (element) => element.id == id,
      orElse: () => MotorRollDirection.unknown,
    );
  }

  R when<R>({
    required R Function() stop,
    required R Function() forward,
    required R Function() reverse,
    required R Function() unknown,
  }) {
    return switch (this) {
      MotorRollDirection.stop => stop(),
      MotorRollDirection.forward => forward(),
      MotorRollDirection.reverse => reverse(),
      MotorRollDirection.unknown => unknown(),
    };
  }

  static MotorRollDirection get random =>
      values[Random().nextInt(values.length)];
}
