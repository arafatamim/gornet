import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Widgets/rounded_card.dart';
import 'package:goribernetflix/Widgets/shimmers.dart';
import 'package:goribernetflix/utils.dart';
import 'package:flutter/material.dart';

import 'package:goribernetflix/Widgets/cover.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<SearchResult>>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildGridView(context, snapshot.data!);
          } else if (snapshot.hasError) {
            return Center(
              child: buildErrorBox(context, snapshot.error),
            );
          } else {
            return Center(
              child: buildErrorBox(context, "No favorites found"),
            );
          }
        } else {
          return const ShimmerList(itemCount: 12);
        }
      },
    );
  }

  Widget _buildGridView(BuildContext context, List<SearchResult> values) {
    final deviceSize = MediaQuery.of(context).size;
    final int itemCount = deviceSize.width ~/ 230;

    return GridView.builder(
      // controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: itemCount,
        childAspectRatio: 0.5,
      ),
      itemCount: values.length,

      itemBuilder: (BuildContext context, int index) {
        SearchResult item = values[index];
        return Cover(
          title: item.name,
          subtitle: "",
          // subtitle: (item.year ?? "").toString(),
          image: item.imageUris?.primary,
          // showIcon: widget.showIcon,
          style: RoundedCardStyle(
            primaryColor: Colors.transparent,
            textColor: Colors.grey.shade300,
            focusTextColor: Colors.white,
            mutedTextColor: Colors.grey.shade400,
            focusMutedTextColor: Colors.grey.shade300,
          ),
          onTap: () {
            Navigator.pushNamed(context, "/detail", arguments: item);
          },
          // onFocus: () {_toEnd(index, 4);}
        );
      },
    );
  }
}
