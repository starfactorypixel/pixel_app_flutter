import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/set_value.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/implementations/set_int8_body.dart';
import 'package:re_seedwork/re_seedwork.dart';

class SpeechProcessingCubit extends Cubit<String> with ConsumerBlocMixin {
  SpeechProcessingCubit({
    required this.dataSource,
    required this.lightsCubit,
    required this.generalInterfacesCubit,
    required this.outgoingPackagesCubit,
    required this.changeGearBloc,
    required this.commandLights,
    required this.commandPowerOn,
    required this.commandPowerOff,
    required this.commandWipers,
    required this.commandHood,
    required this.commandOpen,
    required this.commandClose,
    required this.commandBlink,
    required this.commandHazardLight,
    required this.commandGearDrive,
    required this.commandGearReverse,
    required this.commandGearNeutral,
    required this.commandGearLow,
    required this.commandDoor,
    required this.commandLeft,
    required this.commandRight,
  }) : super('');

  void setState(String textOriginal) {
    final text = textOriginal.toLowerCase();
    emit(text);
    listenLightCabin(text);
    listenDoors(text);
    listenWipers(text);
    listenLightHazardThanks(text);
    listenLightHazard(text);
    listenSuspension(text);
    listenSteeringRack(text);
    listenHood(text);
    listenTransmission(text);

    //ближний дальний свет
    //поворотники
  }

  void listenLightCabin(String text) {
    if (text.contains(commandLights)) {
      if (text.contains(commandPowerOn)) {
        lightsCubit.enableCabinLight();
      } else if (text.contains(commandPowerOff)) {
        lightsCubit.disableCabinLight();
      }
    }
  }

  void listenWipers(String text) {
    if (text.contains(commandWipers)) {
      if (text.contains(commandPowerOn)) {
        generalInterfacesCubit.enableWipers();
      } else if (text.contains(commandPowerOff)) {
        generalInterfacesCubit.disableWipers();
      }
    }
  }

  void listenHood(String text) {
    if (text.contains(commandHood)) {
      if (text.contains(commandOpen)) {
        final package = OutgoingSetValuePackage(
          parameterId: const DataSourceParameterId.hood(),
          setValueBody: const SetInt8Body(value: 100),
        );
        outgoingPackagesCubit.sendPackage(package);
      } else if (text.contains(commandClose)) {
        final package = OutgoingSetValuePackage(
          parameterId: const DataSourceParameterId.hood(),
          setValueBody: const SetInt8Body(value: 0),
        );
        outgoingPackagesCubit.sendPackage(package);
      }
    }
  }

  void listenLightHazardThanks(String text) {
    if (_timerHazardThanks != null) return;

    if (text.contains(commandBlink) && text.contains(commandHazardLight)) {
      lightsCubit.enableHazardLight();
      _timerHazardThanks = Timer(const Duration(seconds: 2), () {
        lightsCubit.disableHazardLight();
        _timerHazardThanks = null;
      });
    }
  }

  void listenLightHazard(String text) {
    if (text.contains(commandHazardLight)) {
      if (text.contains(commandPowerOn)) {
        if (_timerHazardThanks != null) {
          _timerHazardThanks?.cancel();
          _timerHazardThanks = null;
        }
        lightsCubit.enableHazardLight();
      }
      if (text.contains(commandPowerOff)) {
        if (_timerHazardThanks != null) {
          _timerHazardThanks?.cancel();
          _timerHazardThanks = null;
        }
        lightsCubit.disableHazardLight();
      }
    }
  }

  void listenSuspension(String text) {
    //todo
    //подвеска заниженный, шоссе, оффроуд
  }

  void listenSteeringRack(String text) {
    //todo
    //рейка свободный, выравнивание, танковый поворот, крабовый ход, заблокированный
  }

  void listenTransmission(String text) {
    if (text.contains(commandPowerOn)) {
      if (text.contains(commandGearDrive)) {
        changeGearBloc.add(const ChangeGearEvent.change(MotorGear.drive));
      }
      if (text.contains(commandGearReverse)) {
        changeGearBloc.add(const ChangeGearEvent.change(MotorGear.reverse));
      }
      if (text.contains(commandGearLow)) {
        changeGearBloc.add(const ChangeGearEvent.change(MotorGear.low));
      }
      if (text.contains(commandGearNeutral)) {
        changeGearBloc.add(const ChangeGearEvent.change(MotorGear.neutral));
      }
    }
  }

  void listenDoors(String text) {
    if (text.contains(commandDoor)) {
      if (text.contains(commandOpen) && text.contains(commandRight)) {
        generalInterfacesCubit.openDoorRight();
      } else if (text.contains(commandOpen) && text.contains(commandLeft)) {
        generalInterfacesCubit.openDoorLeft();
      } else if (text.contains(commandClose) && text.contains(commandRight)) {
        generalInterfacesCubit.closeDoorRight();
      } else if (text.contains(commandClose) && text.contains(commandLeft)) {
        generalInterfacesCubit.closeDoorLeft();
      }
    }
  }

  @protected
  final DataSource dataSource;

  final LightsCubit lightsCubit;

  final GeneralInterfacesCubit generalInterfacesCubit;

  final OutgoingPackagesCubit outgoingPackagesCubit;

  final ChangeGearBloc changeGearBloc;

  Timer? _timerHazardThanks;

  final String commandLights;
  final String commandPowerOn;
  final String commandPowerOff;
  final String commandWipers;
  final String commandHood;
  final String commandOpen;
  final String commandClose;
  final String commandBlink;
  final String commandHazardLight;
  final String commandGearDrive;
  final String commandGearReverse;
  final String commandGearNeutral;
  final String commandGearLow;
  final String commandDoor;
  final String commandLeft;
  final String commandRight;
}
