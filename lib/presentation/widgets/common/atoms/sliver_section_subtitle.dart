import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';

class SliverSectionSubtitle extends StatelessWidget {
  const SliverSectionSubtitle({
    super.key,
    required this.subtitle,
    this.onInfoPressed,
  });

  @protected
  final String subtitle;

  @protected
  final void Function()? onInfoPressed;

  @protected
  static const kTextStyle = TextStyle(
    height: 1.2,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                subtitle,
                style: kTextStyle.copyWith(color: context.colors.text),
              ),
            ),
            if (onInfoPressed != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: onInfoPressed,
                color: context.colors.text,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
