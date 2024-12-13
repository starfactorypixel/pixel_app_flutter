import 'dart:io' as io;

import 'package:flutter/foundation.dart';

final class Platform {
  static bool get isWeb => kIsWeb;

  static bool get isAndroid => !isWeb && io.Platform.isAndroid;

  static bool get isIOS => !isWeb && io.Platform.isIOS;

  static bool get isMacOS => !isWeb && io.Platform.isMacOS;

  static bool get isWindows => !isWeb && io.Platform.isWindows;

  static bool get isLinux => !isWeb && io.Platform.isLinux;

  static bool get isFuchsia => !isWeb && io.Platform.isFuchsia;
}
