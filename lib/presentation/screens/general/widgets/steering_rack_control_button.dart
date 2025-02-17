import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';

class SteeringRackControlButton extends StatelessWidget {
  const SteeringRackControlButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SteeringRackControlBloc, SteeringRackControlState>(
      builder: (context, state) {
        return SizedBox(
          width: 120,
          child: ActionChip(
            avatar: const Icon(
              Icons.swap_horiz_rounded,
              size: 17,
            ),
            labelStyle:
                const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            label: Center(
              child: Text(
                state.payload.when(
                  alignment: () => context.l10n.alignmentSteeringRack,
                  blocked: () => context.l10n.blockedSteeringRack,
                  crabWalk: () => context.l10n.crabWalkSteeringRack,
                  free: () => context.l10n.freeSteeringRack,
                  tankTurn: () => context.l10n.tankTurnSteeringRack,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            onPressed: () {
              context.router.push(const SteeringRackControlDialogRoute());
            },
          ),
        );
      },
    );
  }
}
