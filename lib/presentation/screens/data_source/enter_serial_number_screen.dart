import 'package:auto_route/annotations.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/atoms/gradient_scaffold.dart';
import 'package:re_seedwork/re_seedwork.dart';
import 'package:re_widgets/re_widgets.dart';

@RoutePage()
class EnterSerialNumberScreen extends StatefulWidget {
  const EnterSerialNumberScreen({
    super.key,
    required this.dswa,
    required this.deviceId,
  });

  @protected
  final DataSourceWithAddress dswa;

  @protected
  final String deviceId;

  @override
  State<EnterSerialNumberScreen> createState() =>
      _EnterSerialNumberScreenState();
}

class _EnterSerialNumberScreenState extends State<EnterSerialNumberScreen> {
  final serialNumberNotifier = _SerialNumberNotifier();

  @override
  void dispose() {
    serialNumberNotifier.dispose();
    super.dispose();
  }

  @protected
  static const kTitleTextStyle = TextStyle(
    height: 1.2,
    fontSize: 17,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
  );

  @protected
  static const kHintTextStyle = TextStyle(
    height: 1.2,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w300,
  );

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.enterSerialNumberMessage,
                        style: kTitleTextStyle.copyWith(
                          color: context.colors.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.enterSerialNumberHintMessage,
                        textAlign: TextAlign.center,
                        style: kHintTextStyle.copyWith(
                          color: context.colors.hintText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _EnterSerialNumberFields(
                serialNumberNotifier: serialNumberNotifier,
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<List<int>>(
                valueListenable: serialNumberNotifier,
                builder:
                    (BuildContext context, List<int> value, Widget? child) {
                  return ElevatedButton(
                    onPressed: serialNumberNotifier.valid
                        ? () {
                            SerialNumber? sn;
                            try {
                              sn = SerialNumber(value);
                            } on Exception catch (_) {
                              context.showSnackBar(
                                context.l10n.errorFormatingSerialNumberMessage,
                              );
                            }

                            if (sn == null) return;

                            context
                                .read<DataSourceAuthorizationCubit>()
                                .authorize(
                                  dswa: widget.dswa,
                                  chain: SerialNumberChain.now(
                                    id: widget.deviceId,
                                    sn: sn,
                                  ),
                                );
                          }
                        : null,
                    child: Text(context.l10n.setButtonCaption),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SerialNumberNotifier extends ValueNotifier<UnmodifiableListView<int>> {
  _SerialNumberNotifier({
    this.bytes = 8,
  }) : super(UnmodifiableListView(List.generate(bytes, (index) => 0x100)));

  @protected
  final int bytes;

  bool get valid {
    return value.length == bytes && value.every((element) => element <= 0xFF);
  }

  void replaceByteValue(int index, String value) {
    final v = [...this.value];
    v[index] = value.length < 2 ? 0x100 : int.parse(value, radix: 16);
    this.value = UnmodifiableListView(v);
  }
}

class _EnterSerialNumberFields extends StatefulWidget {
  const _EnterSerialNumberFields({
    required this.serialNumberNotifier,
  });

  @protected
  final _SerialNumberNotifier serialNumberNotifier;

  @override
  State<_EnterSerialNumberFields> createState() =>
      _EnterSerialNumberFieldsState();
}

class _EnterSerialNumberFieldsState extends State<_EnterSerialNumberFields> {
  late final List<(int, TextEditingController, FocusNode)> fieldsAndNodes;

  @override
  void initState() {
    super.initState();
    fieldsAndNodes = List.generate(
      8,
      (index) => (
        index,
        TextEditingController(),
        FocusNode(
          onKeyEvent: (node, event) {
            if (event.logicalKey == LogicalKeyboardKey.backspace) {
              if (fieldsAndNodes[index].$2.text.isEmpty) {
                if (index > 0) {
                  node.previousFocus();
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          },
        ),
      ),
    );

    for (var i = 0; i < fieldsAndNodes.length; i++) {
      final controller = fieldsAndNodes[i].$2;
      controller.addListener(() {
        widget.serialNumberNotifier.replaceByteValue(i, controller.text);
      });
    }
  }

  @override
  void dispose() {
    for (final element in fieldsAndNodes) {
      element.$2.dispose();
      element.$3.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: fieldsAndNodes
          .map<Widget>(
            (e) => SizedBox(
              width: 30,
              child: TextField(
                controller: e.$2,
                focusNode: e.$3,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.only(left: 2),
                ),
                textAlign: TextAlign.center,
                inputFormatters: [
                  _HexInputFormatter(
                    onFill: () {
                      final node = e.$3;
                      if (!node.hasFocus) return;
                      final index = e.$1;
                      if (index == fieldsAndNodes.length - 1) return;
                      final nextController = fieldsAndNodes[index + 1].$2;
                      if (nextController.text.isNotEmpty) return;
                      node.nextFocus();
                    },
                    onOverfill: (value) {},
                  ),
                ],
              ),
            ),
          )
          .divideBy(const SizedBox(width: 8))
          .toList(),
    );
  }
}

class _HexInputFormatter extends TextInputFormatter {
  _HexInputFormatter({
    required this.onOverfill,
    required this.onFill,
  });

  final void Function(String value) onOverfill;
  final void Function() onFill;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }
    if (newValue.text.length > 2) {
      onOverfill(newValue.text.substring(2));
      return oldValue;
    }
    if (RegExp(r'^([0-9]|[a-fA-F]){0,2}$').hasMatch(newValue.text)) {
      if (oldValue.text.length == 1 && newValue.text.length == 2) onFill();
      return newValue.copyWith(text: newValue.text.toUpperCase());
    }
    return oldValue;
  }
}
