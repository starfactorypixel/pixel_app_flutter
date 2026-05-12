import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_app_flutter/domain/data_source/blocs/SpeechProcessingCubit.dart';
import 'package:pixel_app_flutter/domain/data_source/blocs/mic_data_cubit.dart';
import 'package:pixel_app_flutter/presentation/app/assets.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/responsive_padding.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/organisms/title_wrapper.dart';

@RoutePage()
class MicScreen extends StatelessWidget {
  const MicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MicDataCubit>().state;
    final textResponsed = context.watch<SpeechProcessingCubit>().state;

    return ResponsivePadding(
      child: TitleWrapper(
          title: title(state),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  width: 500,
                  height: 500,
                  getImage(state),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text("Text responded: $textResponsed"),
              ),
            ],
          )),
    );
  }

  String title(MicState state) {
    switch (state) {
      case MicState.initializing:
        return "init";
      case MicState.error:
        return "not responded";
      case MicState.waiting:
        return "waiting";
      case MicState.listening:
        return "listening";
      case MicState.result:
        return "result";
      case MicState.initError:
        return "init error";
    }
  }

  String getImage(MicState state) {
    switch (state) {
      case MicState.initializing:
        return MicImages.micLoading;
      case MicState.error:
        return MicImages.micErrorProcessing;
      case MicState.waiting:
        return MicImages.micLoading;
      case MicState.listening:
        return MicImages.micListening;
      case MicState.result:
        return MicImages.micSuccess;
      case MicState.initError:
        return MicImages.micErrorLoading;
    }
  }
}
