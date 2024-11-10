import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/developer_tools/developer_tools.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';

@RoutePage()
class RequestsExchangeLogsFilterScreen extends StatelessWidget {
  const RequestsExchangeLogsFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: context.router.maybePop,
        ),
        title: Text(context.l10n.requestsFilterScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: () {
              context.read<RequestsExchangeLogsFilterCubit>().update(
                    const RequestsExchangeLogsFilterState(),
                  );
            },
          ),
        ],
      ),
      body: BlocBuilder<RequestsExchangeLogsFilterCubit,
          RequestsExchangeLogsFilterState>(
        builder: (context, state) {
          return ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                ListTile(
                  title: Text(context.l10n.parameterIdListTileLabel),
                  trailing: Text(state.parameterId.join(', ')),
                  onTap: () {
                    context.router
                        .push<List<int>>(
                      FilterParameterIdDialogRoute(
                        title: context.l10n.parameterIdFilterDialogTitle,
                        alwasysVisibleOptions: DataSourceParameterId.all
                            .map((e) => e.value)
                            .toList(),
                        initialChoosedOptions: state.parameterId,
                      ),
                    )
                        .then((value) {
                      if (value != null && context.mounted) {
                        final cubit =
                            context.read<RequestsExchangeLogsFilterCubit>();

                        cubit.update(cubit.state.copyWith(parameterId: value));
                      }
                    });
                  },
                ),
                ListTile(
                  title: Text(context.l10n.requestTypeListTileLabel),
                  trailing: Text(state.requestType.join(', ')),
                  onTap: () {
                    context.router
                        .push<List<int>>(
                      FilterRequestTypeDialogRoute(
                        title: context.l10n.requestTypeFilterDialogTitle,
                        alwasysVisibleOptions: DataSourceRequestType.values
                            .map((e) => e.value)
                            .toList(),
                        initialChoosedOptions: state.requestType,
                      ),
                    )
                        .then((value) {
                      if (value != null && context.mounted) {
                        final cubit =
                            context.read<RequestsExchangeLogsFilterCubit>();

                        cubit.update(cubit.state.copyWith(requestType: value));
                      }
                    });
                  },
                ),
                ListTile(
                  title: Text(context.l10n.requestDirectionListTileLabel),
                  trailing: Text(state.direction.join(', ')),
                  onTap: () {
                    context.router
                        .push<List<int>>(
                      FilterRequestTypeDialogRoute(
                        title: context.l10n.requestDirectionFilterDialogTitle,
                        alwasysVisibleOptions: DataSourceRequestDirection.values
                            .map((e) => e.value)
                            .toList(),
                        initialChoosedOptions: state.direction,
                      ),
                    )
                        .then((value) {
                      if (value != null && context.mounted) {
                        final cubit =
                            context.read<RequestsExchangeLogsFilterCubit>();

                        cubit.update(cubit.state.copyWith(direction: value));
                      }
                    });
                  },
                ),
              ],
            ).toList(),
          );
        },
      ),
    );
  }
}
