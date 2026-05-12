import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:re_seedwork/re_seedwork.dart';

enum Screens{ home, about, navigation, apps, batteries, engines, mic }

class CurrentScreenCubit extends Cubit<Screens> with ConsumerBlocMixin {
  CurrentScreenCubit({
    required this.dataSource,
  }) : super(Screens.home);

  void setState(Screens screen) {
    emit(screen);
  }

  @protected
  final DataSource dataSource;
}
