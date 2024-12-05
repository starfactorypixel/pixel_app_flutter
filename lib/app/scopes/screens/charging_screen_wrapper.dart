import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/charging_screen.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChargingScreenWrapper extends StatelessWidget
    implements AutoRouteWrapper {
  const ChargingScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChargingScreen();
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) {
            context
                .read<OutgoingPackagesCubit>()
                .subscribeTo(BatteryDataCubit.kDefaultSubscribeParameters);
            return BatteryDataCubit(
              dataSource: context.read(),
              // TODO(Radomir): implement dynamic arguments passing
              // when esp32 will be able to send battery,
              // cells and temperature sensors count
              batteriesCount: 2,
              cellsCount: 20,
              temperatureSensorsCount: 10,
            );
          },
        ),
      ],
      child: this,
    );
  }
}
