import 'package:deferred_type/deferred_type.dart';
import 'package:flutter/material.dart';
import 'package:goribernetflix/freezed/detail_arguments.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/section.dart';
import 'package:goribernetflix/widgets/cover.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/grid.dart';
import 'package:goribernetflix/widgets/shimmers.dart';

class ItemsTab extends StatefulWidget {
  final List<Section> sections;
  final bool showIcon;

  const ItemsTab({
    required this.sections,
    this.showIcon = false,
  });
  @override
  _ItemsTabState createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab>
    with AutomaticKeepAliveClientMixin {
  int get itemCount {
    final deviceSize = MediaQuery.of(context).size;
    final int itemCount = deviceSize.width ~/ 200;
    return itemCount;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Widget> buildSections() => <Widget>[
          for (int i = 0; i < widget.sections.length; i++)
            FutureBuilder2<List<SearchResult>>(
              future: widget.sections[i].itemFetcher,
              builder: (context, state) => state.maybeWhen(
                success: (items) {
                  if (widget.sections[i].title != null && items.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sections[i].title!.toUpperCase(),
                          style: Theme.of(context).textTheme.headline2?.apply(
                                fontSizeFactor: 0.6,
                                color: Colors.grey.shade300,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _buildItemsView(context, items)
                      ],
                    );
                  } else {
                    return _buildItemsView(context, items);
                  }
                },
                error: (error, _) {
                  return Center(
                    child: ErrorMessage(error),
                  );
                },
                orElse: () => SizedBox(
                  height: 300,
                  child: ShimmerList(itemCount: itemCount),
                ),
              ),
            ),
        ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildSections(),
      ),
    );
  }

  Widget _buildItemsView(BuildContext context, List<SearchResult> items) {
    return Grid(
      columnCount: itemCount,
      children: [
        for (final item in items)
          AspectRatio(
            aspectRatio: 0.53,
            child: Cover(
              title: item.name,
              subtitle: (item.year ?? "").toString(),
              image: item.imageUris?.primary,
              color: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.focused)
                    ? Colors.white
                    : Colors.transparent,
              ),
              foregroundColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.focused)
                    ? Colors.white
                    : Colors.grey.shade300,
              ),
              mutedForegroundColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.focused)
                    ? Colors.grey.shade300
                    : Colors.grey.shade400,
              ),
              onTap: () {
                Navigator.pushNamed(context, "/detail",
                    arguments: DetailArgs.media(item));
              },
            ),
          ),
      ],
    );
  }
}
