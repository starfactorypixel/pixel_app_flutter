import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/periodic_value_status.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/extensions.dart';

class ChargingScreenListTile<T> extends StatelessWidget {
  const ChargingScreenListTile({
    super.key,
    required this.title,
    required this.values,
    required this.valueMapper,
  });

  @protected
  final String title;

  @protected
  final List<T> values;

  @protected
  final (String, PeriodicValueStatus?) Function(T value) valueMapper;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 2,
        children: List.generate(
          values.length,
          (index) {
            final showIndex = values.length > 1;
            final valueAndStatus = valueMapper(values[index]);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valueAndStatus.$1,
                  style: TextStyle(
                    color: context.colorFromStatus(
                      valueAndStatus.$2 ?? PeriodicValueStatus.normal,
                    ),
                  ),
                ),
                if (showIndex)
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: context.colors.background,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
