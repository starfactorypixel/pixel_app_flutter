import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/mini_progress_indicator.dart';
import 'package:re_seedwork/re_seedwork.dart';

class WipersSwitcherButton extends StatelessWidget {
  const WipersSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GeneralInterfacesCubit, GeneralInterfacesState,
        AsyncData<bool, ToggleStateError>>(
      selector: (state) => state.wipers,
      builder: (context, state) {
        return SizedBox(
          width: 120,
          child: FilterChip(
            avatar: state.maybeWhen(
              orElse: (_) => const Icon(
                Icons.water_drop,
                size: 17,
              ),
              loading: (p) {
                if (p) return const MiniProgreesIndicator();
                return const MiniProgreesIndicator.onPrimary();
              },
            ),
            labelStyle:
                const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            label: Center(
              child: Text(
                context.l10n.windscreenWipersInterfaceTitle,
                textAlign: TextAlign.center,
              ),
            ),
            onSelected: (value) {
              if (state.isLoading) return;
              context.read<GeneralInterfacesCubit>().toggleWindscreenWipers();
            },
            selected: state.payload,
            showCheckmark: false,
          ),
        );
      },
    );
  }
}
