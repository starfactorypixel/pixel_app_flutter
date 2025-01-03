import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:re_seedwork/re_seedwork.dart';

@RoutePage(name: 'SelectDeviceDialogRoute')
class SelectDeviceDialog extends StatefulWidget {
  const SelectDeviceDialog({super.key, required this.dataSource});

  @protected
  final DataSource dataSource;

  @override
  State<SelectDeviceDialog> createState() => _SelectDeviceDialogState();
}

class _SelectDeviceDialogState extends State<SelectDeviceDialog> {
  late final DataSourceDeviceListCubit dataSourceDeviceListCubit;

  @override
  void initState() {
    super.initState();
    dataSourceDeviceListCubit = DataSourceDeviceListCubit(
      dataSource: widget.dataSource,
    )..init();
  }

  @override
  void dispose() {
    dataSourceDeviceListCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.selectDeviceDialogTitle),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .6,
        ),
        child:
            BlocBuilder<DataSourceDeviceListCubit, DataSourceDeviceListState>(
          bloc: dataSourceDeviceListCubit,
          builder: (context, state) {
            return state.maybeWhen(
              orElse: (_) {
                return const UnconstrainedBox(
                  child: SizedBox.square(
                    dimension: 30,
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              failure: (payload, error) {
                return Text(context.l10n.errorDiscoveringDevicesMessage);
              },
              success: (payload) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(context.l10n.deviceNameDialogLabel),
                      trailing: Text(context.l10n.bondedDialogLabel),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...state.payload.map<Widget>(
                              (e) {
                                final selectedDs =
                                    context.watch<DataSourceCubit>().state.ds;
                                final isSelected = selectedDs.when(
                                  undefined: () => false,
                                  presented: (value) =>
                                      value.address == e.address,
                                );

                                return ListTile(
                                  title: Text(
                                    e.name ??
                                        context.l10n.noDeviceNameDialogStub,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColors.of(context).primary
                                          : AppColors.of(context).border,
                                    ),
                                  ),
                                  tileColor: isSelected
                                      ? AppColors.of(context)
                                          .primary
                                          .withValues(alpha: .15)
                                      : null,
                                  subtitle: Text(e.address),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    context.read<DataSourceConnectBloc>().add(
                                          DataSourceConnectEvent.connect(
                                            DataSourceWithAddress(
                                              dataSource: widget.dataSource,
                                              address: e.address,
                                            ),
                                          ),
                                        );
                                  },
                                  trailing: e.isBonded
                                      ? Icon(
                                          Icons.check,
                                          size: 20,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : null,
                                );
                              },
                            ).divideBy(
                              const SizedBox(height: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(context.l10n.cancelButtonCaption),
        ),
      ],
    );
  }
}
