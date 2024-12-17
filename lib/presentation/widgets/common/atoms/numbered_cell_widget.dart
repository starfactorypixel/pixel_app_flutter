import 'package:flutter/widgets.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/extensions.dart';

class NumberedCellWidget extends StatelessWidget {
  const NumberedCellWidget({
    super.key,
    required this.number,
    required this.content,
    required this.status,
  });

  @protected
  final int number;

  @protected
  final String content;

  @protected
  final PeriodicValueStatus? status;

  static const kRadius = Radius.circular(6);

  @protected
  static const kNumberTextStyle = TextStyle(
    height: 1.21,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
  );

  @protected
  static const kContentTextStyle = TextStyle(
    height: 1.21,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    final color =
        context.colorFromStatus(status ?? PeriodicValueStatus.normal) ??
            context.colors.successPastel;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(kRadius),
        border: Border.all(
          color: color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: kRadius),
              color: color,
            ),
            child: Text(
              '#$number',
              textAlign: TextAlign.center,
              style: kNumberTextStyle.copyWith(
                color: context.colors.disabled,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  content,
                  style: kContentTextStyle.copyWith(color: context.colors.text),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
