import 'dart:math' show Random;

enum SteeringRack {
  free(0),
  alignment(1),
  tankTurn(2),
  crabWalk(3),
  blocked(4);

  const SteeringRack(this.id);

  final int id;

  static SteeringRack fromId(int id) {
    return SteeringRack.values.firstWhere(
      (element) => element.id == id,
    );
  }

  T when<T>({
    required T Function() free,
    required T Function() alignment,
    required T Function() tankTurn,
    required T Function() crabWalk,
    required T Function() blocked,
  }) {
    return switch (this) {
      SteeringRack.free => free(),
      SteeringRack.alignment => alignment(),
      SteeringRack.tankTurn => tankTurn(),
      SteeringRack.crabWalk => crabWalk(),
      SteeringRack.blocked => blocked(),
    };
  }

  static SteeringRack get random => values[Random().nextInt(values.length)];
}
