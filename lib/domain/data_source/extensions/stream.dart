extension WaitForStreamExtension on Stream<dynamic> {
  Future<void> waitForType<T>({
    required Future<bool> Function() action,
    required Future<void> Function(T value) onDone,
    required Duration timeout,
  }) async {
    final future = firstWhere((package) => package is T).timeout(timeout);

    final stop = await action();

    if (stop) return;

    await onDone((await future) as T);
  }
}
