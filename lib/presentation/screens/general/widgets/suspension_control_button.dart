import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';

class SuspensionControlButton extends StatelessWidget {
  const SuspensionControlButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuspensionControlBloc, SuspensionControlState>(
      builder: (context, state) {
        return SizedBox(
          width: 120,
          child: ActionChip(
            avatar: const Icon(
              Icons.unfold_more_sharp,
              size: 17,
            ),
            labelStyle:
                const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            label: Center(
              child: Text(
                state.payload.when(
                  off: () => context.l10n.offSuspensionMode,
                  low: () => context.l10n.lowSuspensionMode,
                  highway: () => context.l10n.highwaySuspensionMode,
                  offRoad: () => context.l10n.offRoadSuspensionMode,
                  manual: (value) =>
                      context.l10n.manualValueSuspensionMode(value),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            onPressed: () {
              context.router.push(const SuspensionControlDialogRoute());
            },
          ),
        );
      },
    );
  }
}
