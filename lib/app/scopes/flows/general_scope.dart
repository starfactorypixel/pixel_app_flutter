import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/led_panel/led_panel.dart';
import 'package:pixel_app_flutter/domain/user_defined_buttons/user_defined_buttons.dart';
import 'package:provider/provider.dart';

@RoutePage(name: 'GeneralFlow')
class GeneralScope extends AutoRouter {
  const GeneralScope({super.key});

  @override
  Widget Function(BuildContext context, Widget content)? get builder {
    return (context, content) {
      return MultiProvider(
        providers: [
          // blocs
          BlocProvider(
            create: (context) {
             /* context
                  .read<OutgoingPackagesCubit>()
                  .subscribeTo({const CustomImageParameterId()});
*/
              return LEDPanelSwitcherCubit(
                dataSource: context.read(),
              );
            },
          ),
          BlocProvider(
            create: (context) => UserDefinedButtonsCubit(
              storage: context.read(),
            )..load(),
          ),
          BlocProvider(
            create: (context) => RemoveUserDefinedBurronBloc(
              storage: context.read(),
            ),
          ),
        ],
        child: content,
      );
    };
  }
}
