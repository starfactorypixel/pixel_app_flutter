import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/extensions.dart';
import 'package:pixel_app_flutter/presentation/app/icons.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/led_switcher_button.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/suspension_control_button.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/wipers_switcher_button.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/icon_button.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/relay_widget.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/molecules/trunk_joystick.dart';
import 'package:pixel_app_flutter/presentation/widgets/tablet/atoms/car_interface_pointer.dart';
import 'package:pixel_app_flutter/presentation/widgets/tablet/molecules/car_interface_switcher.dart';
import 'package:re_seedwork/re_seedwork.dart';
import 'package:re_widgets/re_widgets.dart';

class CarWidget extends StatefulWidget {
  const CarWidget({super.key});

  @override
  State<CarWidget> createState() => _CarWidgetState();
}

class _CarWidgetState extends State<CarWidget> {
  final turnSignalRelayCubit = TurnSignalRelayCubit()..enable();

  Size carSize = Size.zero;

  IconData _getIcon(bool opened) =>
      opened ? PixelIcons.unlocked : PixelIcons.locked;

  @protected
  static const carAssetPath = 'assets/svg/car.svg';

  @override
  void dispose() {
    turnSignalRelayCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonScaleCoef = (carSize.width / 232).clamp(0.0, 1.0);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;

    return Align(
      alignment: const Alignment(.4, 0),
      child: UnboundedHitTestStack(
        clipBehavior: Clip.none,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width * .26,
              maxHeight: width.flexSize(
                screenFlexRange: (700, 1100),
                valueClampRange: (height * .48, height * .58),
              ),
            ),
            child: MeasureSize(
              onChange: (size) {
                if (size != carSize) {
                  carSize = size;
                  if (mounted) setState(() {});
                }
              },
              child: AspectRatio(
                aspectRatio: .3972,
                child: SvgPicture.asset(carAssetPath),
              ),
            ),
          ),
          if (carSize != Size.zero) ...[
            // Cabin light
            Positioned.fill(
              child: BlocSelector<LightsCubit, LightsState,
                  AsyncData<bool, ToggleStateError>>(
                selector: (state) => state.cabin,
                builder: (context, state) {
                  final buttonState = state.maybeWhen(
                    orElse: (payload) => PIconButtonState.enabled,
                    success: (payload) {
                      return payload
                          ? PIconButtonState.success
                          : PIconButtonState.error;
                    },
                  );
                  return Center(
                    child: Transform.scale(
                      scale: buttonScaleCoef,
                      child: CarInterfaceSwitcher(
                        icon: PixelIcons.light,
                        state: buttonState,
                        onPressed: context.read<LightsCubit>().toggleCabinLight,
                        title: context.l10n.cabinLightButtonCaption,
                        status: state.payload
                            ? context.l10n.onShortStatusMessage
                            : context.l10n.offShortStatusMessage,
                        titleSide: CarInterfaceSwitcherTitleSide.bottom,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Left door
            Positioned(
              top: 0,
              right: carSize.width * .88,
              bottom: 0,
              child: Transform.scale(
                scale: buttonScaleCoef,
                alignment: Alignment.centerRight,
                child: BlocSelector<GeneralInterfacesCubit,
                    GeneralInterfacesState, AsyncData<bool, ToggleStateError>>(
                  selector: (state) => state.leftDoor,
                  builder: (context, state) {
                    return CarInterfaceSwitcher(
                      icon: _getIcon(state.payload),
                      state: state.buttonState,
                      onPressed:
                          context.read<GeneralInterfacesCubit>().toggleLeftDoor,
                      title: context.l10n.doorInterfaceTitle,
                      status: context.getStatus(state),
                      pointerSide: CarInterfacePointerSide.right,
                      titleSide: CarInterfaceSwitcherTitleSide.left,
                    );
                  },
                ),
              ),
            ),
            // Right door
            Positioned(
              top: 0,
              left: carSize.width * .88,
              bottom: 0,
              child: Transform.scale(
                scale: buttonScaleCoef,
                alignment: Alignment.centerLeft,
                child: BlocSelector<GeneralInterfacesCubit,
                    GeneralInterfacesState, AsyncData<bool, ToggleStateError>>(
                  selector: (state) => state.rightDoor,
                  builder: (context, state) {
                    return CarInterfaceSwitcher(
                      icon: _getIcon(state.payload),
                      state: state.buttonState,
                      onPressed: context
                          .read<GeneralInterfacesCubit>()
                          .toggleRightDoor,
                      title: context.l10n.doorInterfaceTitle,
                      status: context.getStatus(state),
                      pointerSide: CarInterfacePointerSide.left,
                      titleSide: CarInterfaceSwitcherTitleSide.right,
                    );
                  },
                ),
              ),
            ),
            // Hood
            Positioned(
              top: carSize.height * .02,
              right: 0,
              left: 0,
              child: Center(
                child: TrunkJoystick.big(
                  parameterId: const DataSourceParameterId.hood(),
                  sizeFactor: buttonScaleCoef,
                ),
              ),
            ),
            // Trunk
            Positioned(
              bottom: carSize.height * .02,
              right: 0,
              left: 0,
              child: Center(
                child: TrunkJoystick.big(
                  parameterId: const DataSourceParameterId.trunk(),
                  sizeFactor: buttonScaleCoef,
                ),
              ),
            ),
            // LED Switcher button
            const Positioned(
              bottom: 0,
              left: -140,
              child: LEDSwitcherButton(),
            ),
            // Suspension
            const Positioned(
              bottom: 50,
              left: -140,
              child: SuspensionControlButton(),
            ),
            // Windscreen wipers
            const Positioned(
              top: 0,
              left: -140,
              child: WipersSwitcherButton(),
            ),
          ],
        ],
      ),
    );
  }
}

extension on BuildContext {
  String getStatus(AsyncData<bool, ToggleStateError> state) {
    return state.maybeWhen(
      orElse: (payload) {
        return payload
            ? l10n.unlockedInterfaceStatus
            : l10n.lockedInterfaceStatus;
      },
      loading: (payload) => l10n.waitingInterfaceStatus,
    );
  }
}

extension on AsyncData<bool, ToggleStateError> {
  PIconButtonState get buttonState {
    return maybeWhen(
      orElse: (payload) {
        return payload ? PIconButtonState.success : PIconButtonState.error;
      },
      loading: (_) => PIconButtonState.enabled,
    );
  }
}
