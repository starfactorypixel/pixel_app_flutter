import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/presentation/screens/general/general_screen.dart';
import 'package:provider/provider.dart';

class GeneralScreenWrapper extends StatelessWidget with AutoRouteWrapper {
  const GeneralScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralScreen();
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) {
            context
                .read<OutgoingPackagesCubit>()
                .subscribeTo(GeneralDataCubit.kDefaultSubscribeParameters);
            return GeneralDataCubit(
              dataSource: context.read(),
            );
          },
        ),
      ],
      child: this,
    );
  }
}