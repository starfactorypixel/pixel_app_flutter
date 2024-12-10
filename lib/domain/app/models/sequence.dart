import 'dart:collection';

class Sequence<T> extends UnmodifiableListView<T> {
  Sequence(
    super.source, {
    required this.expectedLength,
  });

  factory Sequence.fill(int length, T fillValue) {
    return Sequence<T>(
      List<T>.filled(length, fillValue),
      expectedLength: length,
    );
  }

  factory Sequence.fillBuilder(int length, T Function(int index) builder) {
    return Sequence<T>(
      List<T>.generate(length, builder),
      expectedLength: length,
    );
  }

  final int expectedLength;

  Sequence<T> updateAt(int index, T value) {
    return Sequence<T>(
      index == length
          ? [...this, value]
          : [for (var i = 0; i < length; i++) i == index ? value : this[i]],
      expectedLength: expectedLength,
    );
  }

  T? getAt(int index) {
    return index < length ? this[index] : null;
  }
}
