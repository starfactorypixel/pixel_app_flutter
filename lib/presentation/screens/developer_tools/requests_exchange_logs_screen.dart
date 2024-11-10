import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/developer_tools/developer_tools.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/widgets/filter_button.dart';

@RoutePage()
class RequestsExchangeLogsScreen extends StatelessWidget {
  const RequestsExchangeLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(
      routes: const [
        ProcessedExchangeLogsRoute(),
        RawExchangeLogsRoute(),
      ],
      builder: (context, child, tabController) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: context.router.maybePop,
            ),
            title: Text(context.l10n.requestsExchangeLogsScreenTitle),
            actions: [
              const FilterButton(),
              BlocBuilder<PauseLogsUpdatingCubit, bool>(
                builder: (context, pause) {
                  return IconButton(
                    onPressed: () {
                      context.read<PauseLogsUpdatingCubit>().toggle();
                    },
                    icon: Icon(
                      pause ? Icons.play_arrow : Icons.pause,
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: tabController,
              tabs: [
                Tab(text: context.l10n.processedRequestsTabTitle),
                Tab(text: context.l10n.rawRequestsTabTitle),
              ],
            ),
          ),
          body: child,
        );
      },
    );
  }
}
