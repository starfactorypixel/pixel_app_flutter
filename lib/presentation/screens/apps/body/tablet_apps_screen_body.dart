part of '../apps_screen.dart';

class _TabletBody extends StatefulWidget {
  const _TabletBody({
    required this.itemsNotifier,
    required this.eventController,
    required this.searchTextFieldController,
  });

  @protected
  final ItemsNotifier<ApplicationInfo> itemsNotifier;

  @protected
  final DefaultEventController<ApplicationInfo> eventController;

  @protected
  final TextEditingController searchTextFieldController;

  @override
  State<_TabletBody> createState() => _TabletBodyState();
}

class _TabletBodyState extends State<_TabletBody> {
  final scrollController = ScrollController();
  final textFieldHeightNotifier = SearchAppTextFieldHeightNotifier()
    ..setDefaultHeight(40);

  @override
  void dispose() {
    scrollController.dispose();
    textFieldHeightNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 37),
          child: Text(
            context.l10n.appsTabTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * .7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32)
                        .copyWith(top: 37, bottom: 24),
                    child: SearchAppTextField(
                      heightNotifier: textFieldHeightNotifier,
                      controller: widget.searchTextFieldController,
                    ),
                  ),
                  _AppsList(
                    scrollController: scrollController,
                    itemsNotifier: widget.itemsNotifier,
                    eventController: widget.eventController,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppsList extends StatelessWidget {
  const _AppsList({
    required this.scrollController,
    required this.itemsNotifier,
    required this.eventController,
  });

  @protected
  final ScrollController scrollController;

  @protected
  final ItemsNotifier<ApplicationInfo> itemsNotifier;

  @protected
  final DefaultEventController<ApplicationInfo> eventController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchAppCubit, SearchAppState>(
      builder: (context, state) {
        return Expanded(
          child: Scrollbar(
            controller: scrollController,
            child: FadeScrollable(
              createController: () => scrollController,
              disposeController: false,
              scrollable: (_) {
                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                      ).copyWith(bottom: 37),
                      sliver: SliverAnimatedGridView<ApplicationInfo>(
                        items: state.filtered,
                        idMapper: (object) => object.packageName ?? '',
                        itemsNotifier: itemsNotifier,
                        eventController: eventController,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          childAspectRatio: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (item) {
                          return _AppCard(
                            app: item,
                            searchString: state.searchString,
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: AvoidBottomInsetWidget(),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({
    required this.app,
    required this.searchString,
  });

  @protected
  final ApplicationInfo app;

  @protected
  final String searchString;

  @protected
  static const kRadius = Radius.circular(8);

  @protected
  static const kBorderRadius = BorderRadius.all(kRadius);

  @override
  Widget build(BuildContext context) {
    final icon = app.icon;

    return ImagePixels(
      imageProvider: icon == null ? null : MemoryImage(icon),
      builder: (context, img) {
        return Stack(
          children: [
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: img.hasImage
                      ? () {
                          final packageName = app.packageName;
                          if (packageName == null) return;
                          context.read<LaunchAppCubit>().launchApp(packageName);
                        }
                      : null,
                  borderRadius: kBorderRadius,
                  child: Ink(
                    key: ValueKey(app.name),
                    decoration: BoxDecoration(
                      borderRadius: kBorderRadius,
                      color: img.hasImage
                          ? img.pixelColorAtAlignment?.call(
                                Alignment.center,
                              ) ??
                              Colors.white
                          : AppColors.of(context).background,
                    ),
                    child: icon == null
                        ? const Icon(
                            Icons.image_not_supported_outlined,
                          )
                        : img.hasImage
                            ? RawImage(image: img.uiImage)
                            : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            //
            Positioned(
              top: 0,
              right: 0,
              child: Material(
                color: AppColors.of(context).border,
                borderRadius: kBorderRadius.copyWith(
                  topLeft: Radius.zero,
                  bottomRight: Radius.zero,
                ),
                child: InkWell(
                  onTap: () {
                    context.read<ManagePinnedAppsBloc>().add(
                          app.pinned
                              ? ManagePinnedAppsEvent.remove(app)
                              : ManagePinnedAppsEvent.add(app),
                        );
                  },
                  borderRadius: kBorderRadius.copyWith(
                    topLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                  child: Ink(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        app.pinned ? PixelIcons.pin : PixelIcons.pinOutline,
                        size: 13,
                        color: AppColors.of(context).text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //
            if (searchString.isNotEmpty)
              Positioned.fill(
                top: null,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: kBorderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.of(context).border.withValues(alpha: .5),
                        AppColors.of(context).border,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4).copyWith(top: 10),
                    child: AppTitle(
                      highlightInTitle: searchString,
                      fullTitle: app.name,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
