import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:re_seedwork/re_seedwork.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Injectable(as: DeveloperToolsParametersStorage)
class DeveloperToolsParametersStorageImpl
    extends InMemoryValueStore<DeveloperToolsParameters>
    implements DeveloperToolsParametersStorage {
  DeveloperToolsParametersStorageImpl({required this.preferences})
      : super(const DeveloperToolsParameters.defaultValues()) {
    read();
  }

  @protected
  final SharedPreferences preferences;

  @visibleForTesting
  static const kDeveloperToolsParametersKey = 'DeveloperToolsParameters';

  @override
  Result<DeveloperToolsParametersReadError, DeveloperToolsParameters> read() {
    final string = preferences.getString(kDeveloperToolsParametersKey);
    try {
      final map = jsonDecode(string ?? '');
      if (map == null) {
        return const Result.error(DeveloperToolsParametersReadError.noValue);
      }
      final devToolsParams =
          DeveloperToolsParameters.fromMap(map as Map<String, dynamic>);

      put(devToolsParams);
      return Result.value(devToolsParams);
    } on Exception catch (_) {
      return const Result.error(DeveloperToolsParametersReadError.noValue);
    }
  }

  @override
  Future<Result<DeveloperToolsParametersWriteError, void>> write(
    DeveloperToolsParameters parameters,
  ) async {
    final jsonString = jsonEncode(parameters.toMap());
    final success = await preferences.setString(
      kDeveloperToolsParametersKey,
      jsonString,
    );

    if (!success) {
      return const Result.error(DeveloperToolsParametersWriteError.unknown);
    }

    await put(parameters);

    return const Result.value(null);
  }

  @override
  Future<Result<DeveloperToolsParametersRemoveError, void>> remove() async {
    final success = await preferences.remove(kDeveloperToolsParametersKey);
    if (success) return const Result.value(null);

    return const Result.error(DeveloperToolsParametersRemoveError.unknown);
  }

  @override
  DeveloperToolsParameters get defaultValue =>
      const DeveloperToolsParameters.defaultValues();
}
