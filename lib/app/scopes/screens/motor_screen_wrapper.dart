import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/presentation/screens/motor/motor_screen.dart';
import 'package:provider/provider.dart';

@RoutePage()
class MotorScreenWrapper extends StatelessWidget implements AutoRouteWrapper {
  const MotorScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const MotorScreen();
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) {
            context
                .read<OutgoingPackagesCubit>()
                .subscribeTo(MotorDataCubit.kDefaultSubscribeParameters);
            return MotorDataCubit(
              dataSource: context.read(),
              motorsCount: context.read<HardwareCount>().motors,
            );
          },
        ),
      ],
      child: this,
    );
  }
}
