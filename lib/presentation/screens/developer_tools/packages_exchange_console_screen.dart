import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/developer_tools/developer_tools.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/widgets/exchange_log_card.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/widgets/filter_button.dart';
import 'package:re_widgets/re_widgets.dart';

@RoutePage()
class PackagesExchangeConsoleScreen extends StatefulWidget {
  const PackagesExchangeConsoleScreen({super.key});

  @override
  State<PackagesExchangeConsoleScreen> createState() =>
      _PackagesExchangeConsoleScreenState();
}

class _PackagesExchangeConsoleScreenState
    extends State<PackagesExchangeConsoleScreen> {
  final typeController = TextEditingController();
  final idController = TextEditingController();
  final dataController = TextEditingController();

  @protected
  static const kFieldsWidth = 300.0;

  @override
  void dispose() {
    typeController.dispose();
    idController.dispose();
    dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.packagesExchangeConsoleScreenTitle),
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
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ExchangeConsoleLogsCubit,
                List<RawRequestsExchangeLogsState>>(
              buildWhen: (previous, current) {
                return !context.read<PauseLogsUpdatingCubit>().state;
              },
              builder: (context, items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(context.l10n.noPackagesMessage),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  reverse: true,
                  itemBuilder: (context, index) {
                    final reverseIndex = items.length - index - 1;

                    final item = items[reverseIndex];

                    return ExchangeLogCard.fromBytes(
                      bytes: item.data,
                      dateTime: item.dateTime,
                      direction: item.direction,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kFieldsWidth),
                  child: Row(
                    children: [
                      _PackageTextFiled(
                        hint: context.l10n.requestTypeHint,
                        controller: typeController,
                      ),
                      _PackageTextFiled(
                        hint: context.l10n.parameterIDHint,
                        controller: idController,
                      ),
                    ].map((e) => Expanded(child: e)).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kFieldsWidth),
                  child: _PackageTextFiled(
                    hint: context.l10n.packageDataHint,
                    controller: dataController,
                    label: context.l10n.packageDataLabel,
                  ),
                ),
                const SizedBox(height: 16),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: double.infinity,
                        child: IconButton(
                          icon: const Icon(Icons.cleaning_services),
                          onPressed: () {
                            context.read<ExchangeConsoleLogsCubit>().clear();
                            context
                                .read<RequestsExchangeLogsFilterCubit>()
                                .update(
                                  const RequestsExchangeLogsFilterState(),
                                );
                            typeController.clear();
                            idController.clear();
                            dataController.clear();
                          },
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: const RoundedRectangleBorder(),
                          ),
                          icon: const Icon(Icons.send),
                          label: Text(
                            context.l10n.sendButtonCaption,
                            style: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            final requestType =
                                int.tryParse(typeController.text);
                            final parameterId = int.tryParse(idController.text);
                            final data = [
                              if (dataController.text.isNotEmpty)
                                ...dataController.text
                                    .replaceAll(',', ' ')
                                    .split(' ')
                                    .map((e) => int.tryParse(e.trim())),
                            ];
                            if (requestType == null) {
                              context.showSnackBar(
                                context.l10n.invalidRequestTypeMessage,
                              );
                              return;
                            }
                            if (parameterId == null) {
                              context.showSnackBar(
                                context.l10n.invalidParameterIDMessage,
                              );
                              return;
                            }
                            if (data.any((element) => element == null)) {
                              context.showSnackBar(
                                context.l10n.invalidDataFormatMessage,
                              );
                              return;
                            }

                            context
                                .read<RequestsExchangeLogsFilterCubit>()
                                .update(
                                  context
                                      .read<RequestsExchangeLogsFilterCubit>()
                                      .state
                                      .copyWith(parameterId: [parameterId]),
                                );
                            try {
                              context.read<OutgoingPackagesCubit>().sendPackage(
                                    DataSourceOutgoingPackage.raw(
                                      requestType: requestType,
                                      parameterId: parameterId,
                                      data: data.whereType<int>().toList(),
                                    ),
                                  );
                            } on ProviderNotFoundException catch (_) {
                              context.showSnackBar(
                                context.l10n
                                    .exchangeLogsConsoleNoDataSourceMessage,
                              );
                            }

                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageTextFiled extends StatelessWidget {
  const _PackageTextFiled({
    required this.hint,
    required this.controller,
    this.label,
  });

  @protected
  final String hint;

  @protected
  final String? label;

  @protected
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          label: label == null ? null : Text(label ?? ''),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
