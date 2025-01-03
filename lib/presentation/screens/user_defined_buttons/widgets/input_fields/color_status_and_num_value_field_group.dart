import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/user_defined_buttons/user_defined_buttons.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/models/button_properties_manager.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/models/button_property_check/button_property_validators.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/models/button_property_input_field/implementations/color_matcher_input_field.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/models/button_property_input_field/implementations/num_value_getter_input_field.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/models/button_property_input_field/implementations/status_matcher_input_field.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/models/properties_map.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/input_fields/color_matcher_input_fields_widget.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/input_fields/data_matchers_input_fileds_widget.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/input_fields/num_value_getter_input_filed_widget.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/input_fields/status_matcher_input_fields_widget.dart';

class ColorStatusAndNumValueFieldGroupWidget extends StatefulWidget {
  const ColorStatusAndNumValueFieldGroupWidget({
    super.key,
    required this.manager,
    this.initialColorMatcher,
    this.initialStatusMatcher,
    this.initialNumValueGetterParameters,
  });

  @protected
  final ButtonPropertiesManager manager;

  @protected
  final ColorMatcher? initialColorMatcher;

  @protected
  final StringMatcher? initialStatusMatcher;

  @protected
  final NumValueGetterParameters? initialNumValueGetterParameters;

  @override
  State<ColorStatusAndNumValueFieldGroupWidget> createState() =>
      _ColorStatusAndNumValueFieldGroupWidgetState();
}

class _ColorStatusAndNumValueFieldGroupWidgetState
    extends State<ColorStatusAndNumValueFieldGroupWidget> {
  final colorTilesManagerNotifier =
      ValueNotifier<List<DataMatchersModel<Color>>>([]);

  String? validate(
    BuildContext context, [
    ColorMatcherProrpertiesMap? colorMatcher,
    StringMatcherProrpertiesMap? titleMatcher,
    NumValueGetterParameters? numValueGetterParameters,
  ]) {
    final _colorMatcher = {
      ...?colorMatcher ??
          widget.manager.getOptional<ColorMatcherProrpertiesMap,
              ColorMatcherInputField>(),
    }..remove(0);
    final _titleMatcher = {
      ...?titleMatcher ??
          widget.manager.getOptional<StringMatcherProrpertiesMap,
              StatusMatcherInputField>(),
    }..remove(0);
    var numValueGetterParametersEnabled = numValueGetterParameters != null;

    if ([colorMatcher, titleMatcher].any((e) => e == null)) {
      numValueGetterParametersEnabled = widget.manager
          .getValue<SerializablePropertiesMap, NumValueGetterInputField>()
          .getValue<bool, BoolPropertyEntry>();
    }

    if ({..._colorMatcher, ..._titleMatcher}.isEmpty &&
        !numValueGetterParametersEnabled) {
      return context.l10n.emptyColorStatusAndNumValueFieldsHintError;
    }
    return null;
  }

  static const params = PackageDataParameters(
    endian: Endian.big,
    range: ManualDataBytesRange(start: 0, end: 1),
    sign: Sign.unsigned,
  );

  List<DataMatchersModel<Color>> generateDefaultStatusColors(
    BuildContext context,
  ) {
    return [
      DataMatchersModel<Color>(
        1,
        comparisonOperation: ComparisonOperation.equalsTo,
        packageDataParameters: params,
        propertyEntry: ColorPropertyEntry(context.colors.successPastel),
        value: FunctionId.okIncomingPeriodicValueId.toString(),
      ),
      DataMatchersModel<Color>(
        2,
        comparisonOperation: ComparisonOperation.equalsTo,
        packageDataParameters: params,
        propertyEntry: ColorPropertyEntry(context.colors.warning),
        value: FunctionId.warningIncomingPeriodicValueId.toString(),
      ),
      DataMatchersModel<Color>(
        3,
        comparisonOperation: ComparisonOperation.equalsTo,
        packageDataParameters: params,
        propertyEntry: ColorPropertyEntry(context.colors.errorPastel),
        value: FunctionId.criticalIncomingPeriodicValueId.toString(),
      ),
    ];
  }

  SerializablePropertiesMap generateDefaultColorIfStatement(
    int value,
    PropertyEntry<Color> colorPropertyEntry,
  ) {
    return SerializablePropertiesMap({})
        .addProperty(const PackageDataParametersPropertyEntry(params))
        .addProperty(
          const ComparisonOperationPropertyEntry(ComparisonOperation.equalsTo),
        )
        .addProperty(OptionalIntPropertyEntry(value))
        .addProperty(colorPropertyEntry);
  }

  @override
  void dispose() {
    colorTilesManagerNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumValueGetterInputFormFieldWidget(
          manager: widget.manager,
          initialParameters: widget.initialNumValueGetterParameters,
          validator: (params) => validate(context, null, null, params),
        ),
        const SizedBox(height: 16),
        ColorMatcherInputFieldsWidget(
          manager: widget.manager,
          tilesManagerNotifier: colorTilesManagerNotifier,
          validators: [
            ButtonPropertyValidatorWrapper((data) => validate(context, data)),
          ],
          bottom: [
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        context.colors.hintText.withValues(alpha: .2),
                  ),
                  onPressed: () {
                    final defaultColors = generateDefaultStatusColors(context);
                    widget.manager.updateValue<ColorMatcherProrpertiesMap,
                        ColorMatcherInputField>(
                      (currentValue) {
                        final ifStatement = currentValue?[0];
                        return ColorMatcherProrpertiesMap({
                          if (ifStatement != null) 0: ifStatement,
                          for (final e in defaultColors)
                            e.id: generateDefaultColorIfStatement(
                              int.parse(e.value ?? ''),
                              e.propertyEntry!,
                            ),
                        });
                      },
                    );
                    colorTilesManagerNotifier.value = defaultColors;
                  },
                  child: Text(
                    context.l10n.setTheTheDefaultStatusColorsButtonCaption,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
          initialIfMatchersValues: List.generate(
            widget.initialColorMatcher?.ifMatchers.length ?? 0,
            (index) {
              final millis = DateTime.now().millisecondsSinceEpoch;
              final e = (widget.initialColorMatcher?.ifMatchers ?? [])[index];
              return DataMatchersModel<Color>(
                millis + index,
                comparisonOperation: e.operation,
                packageDataParameters: e.parameters,
                propertyEntry: ColorPropertyEntry(e.result),
                value: e.value.toString(),
              );
            },
          ),
          initialElseValue: widget.initialColorMatcher?.elseResult,
          title: context.l10n.colorFieldTitle,
        ),
        const SizedBox(height: 16),
        StatusMatcherInputFieldsWidget(
          manager: widget.manager,
          title: context.l10n.statusFieldTitle,
          initialElseValue: widget.initialStatusMatcher?.elseResult,
          initialIfMatchersValues: List.generate(
            widget.initialStatusMatcher?.ifMatchers.length ?? 0,
            (index) {
              final millis = DateTime.now().millisecondsSinceEpoch;
              final e = (widget.initialStatusMatcher?.ifMatchers ?? [])[index];
              return DataMatchersModel<String>(
                millis + index,
                comparisonOperation: e.operation,
                packageDataParameters: e.parameters,
                propertyEntry: StringPropertyEntry(e.result),
                value: e.value.toString(),
              );
            },
          ),
          validators: [
            ButtonPropertyValidatorWrapper(
              (data) => validate(context, null, data),
            ),
          ],
        ),
      ],
    );
  }
}
