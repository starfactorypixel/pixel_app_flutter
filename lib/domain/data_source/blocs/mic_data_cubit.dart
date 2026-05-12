import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_app_flutter/domain/data_source/blocs/CurrentScreenCubit.dart';
import 'package:pixel_app_flutter/domain/data_source/blocs/SpeechProcessingCubit.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:re_seedwork/re_seedwork.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum MicState { initializing, error, waiting, listening, result, initError }

//https://github.com/csdcorp/speech_to_text/blob/main/speech_to_text/example/lib/main.dart#L469
class MicDataCubit extends Cubit<MicState> with ConsumerBlocMixin {
  MicDataCubit({
    required this.dataSource,
    required this.speechProcessingCubit,
    required this.currentScreenCubit,
  }) : super(MicState.initializing);

  final SpeechToText _speechToText = SpeechToText();
  final SpeechProcessingCubit speechProcessingCubit;
  final CurrentScreenCubit currentScreenCubit;

  Future<void> initListen() async {
    try {
      final isInited = await _speechToText.initialize(
          onError: onSpeechError, onStatus: onSpeechStatus);

      if (isInited) {
        if (currentScreenCubit.state == Screens.mic) {
          startListen();
        } else {
          emit(MicState.waiting);
        }
      } else {
        emit(MicState.initError);
      }
    } catch (e) {
      emit(MicState.initError);
    }
  }

  void init() {
    emit(MicState.initializing);
    initListen();
  }

  void setIsListening(bool value) {
    if (value &&
        (state == MicState.waiting ||
            state == MicState.result ||
            state == MicState.error)) {
      startListen();
    }

    if (!value && state == MicState.listening) {
      stopListen();
    }
  }

  void startListen() {
    emit(MicState.listening);
    _speechToText.listen(
      onResult: resultListener,
    );
  }

  void stopListen() {
    emit(MicState.waiting);
    _speechToText.cancel();
  }

  void resultListener(SpeechRecognitionResult result) {
    if (!result.finalResult) return;
    emit(MicState.result);
    speechProcessingCubit.setState(result.recognizedWords);
    restartListen();
  }

  void onSpeechError(SpeechRecognitionError error) {
    emit(MicState.error);
    restartListen();
  }

  @protected
  final DataSource dataSource;

  void restartListen() {
    timerRestart?.cancel();
    timerRestart = Timer(const Duration(seconds: 2), () {
      if (currentScreenCubit.state != Screens.mic ||
          !(state == MicState.result || state == MicState.error)) {
        return;
      }

      startListen();
    });
  }

  Timer? timerRestart;

  void onSpeechStatus(String status) {
    debugPrint("status $status");
  }
}
