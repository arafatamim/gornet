import 'package:goribernetflix/freezed/detail_arguments.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/shimmers.dart';
import 'package:flutter/material.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:goribernetflix/widgets/cover.dart';

class ItemsTab extends StatefulWidget {
  final Future<List<SearchResult>> future;
  final bool showIcon;

  const ItemsTab({
    required this.future,
    this.showIcon = false,
  });
  @override
  _ItemsTabState createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab>
    with AutomaticKeepAliveClientMixin {
  // ScrollController _scrollController;

  @override
  void initState() {
    // _scrollController = new ScrollController(
    //   initialScrollOffset: 0.0,
    //   keepScrollOffset: true,
    // )
    super.initState();
  }

  @override
  void dispose() {
    // _scrollController.dispose();
    super.dispose();
  }

  // void _toEnd(int index, int items) {
  //   var row = (index/6).floor();
  //   var scrollCursor = row * 250;
  //   // if(scrollCursor != cursor) cursor = scrollCursor;
  //   print("scrolloffset");
  //   print(_scrollController.offset);
  //   print("cursor");
  //   print(cursor);
  //   print("maxscroll");
  //   print(_scrollController.position.maxScrollExtent);
  //   _scrollController.animateTo(                                      // NEW
  //     scrollCursor.toDouble(),                     // NEW
  //     duration: const Duration(milliseconds: 300),                    // NEW
  //     curve: Curves.ease,                                             // NEW
  //   );                                                                // NEW
  // }

  @override
  bool get wantKeepAlive => true;

  int get itemCount {
    final deviceSize = MediaQuery.of(context).size;
    final int itemCount = deviceSize.width ~/ 200;
    return itemCount;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder2<List<SearchResult>>(
      future: widget.future,
      builder: (context, state) => state.maybeWhen(
        success: (items) {
          if (items.isEmpty) {
            return const Center(
              child: ErrorMessage("Watchlist is empty!"),
            );
          }
          return _buildGridView(context, items);
        },
        error: (error, stackTrace) => Center(child: ErrorMessage(error)),
        orElse: () => ShimmerList(itemCount: itemCount),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<SearchResult> values) {
    return GridView.builder(
      // controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: itemCount,
        childAspectRatio: 0.53,
      ),
      itemCount: values.length,

      itemBuilder: (BuildContext context, int index) {
        SearchResult item = values[index];
        return Cover(
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
          // style: CustomTouchableStyle(
          //   primaryColor: Colors.transparent,
          //   textColor: Colors.grey.shade300,
          //   focusTextColor: Colors.white,
          //   mutedTextColor: Colors.grey.shade400,
          //   focusMutedTextColor: Colors.grey.shade300,
          // ),
          onTap: () {
            Navigator.pushNamed(context, "/detail",
                arguments: DetailArgs.media(item));
          },
          // onFocus: () {_toEnd(index, 4);}
        );
      },
    );
  }
}
