import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/numbered_cell_widget.dart';

class CellSliverGridBuilder<B extends BlocBase<S>, S, T>
    extends StatelessWidget {
  const CellSliverGridBuilder({
    super.key,
    required this.itemCount,
    required this.selector,
    required this.contentBuilder,
  });

  final int itemCount;
  final T Function(S state, int index) selector;
  final (String, PeriodicValueStatus?) Function(BuildContext context, T data)
      contentBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 70,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        return BlocSelector<B, S, T>(
          selector: (state) => selector(state, index),
          builder: (context, data) {
            final (content, status) = contentBuilder(context, data);
            return NumberedCellWidget(
              number: index + 1,
              content: content,
              status: status,
            );
          },
        );
      },
    );
  }
}
