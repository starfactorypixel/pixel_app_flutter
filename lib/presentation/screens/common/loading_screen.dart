import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/atoms/gradient_scaffold.dart';

@RoutePage()
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, this.popable = true});

  @protected
  final bool popable;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: PopScope(
        canPop: popable,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

@RoutePage()
class NonPopableLoadingScreen extends LoadingScreen {
  const NonPopableLoadingScreen({super.key}) : super(popable: false);
}
