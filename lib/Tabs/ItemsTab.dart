import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:chillyflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:chillyflix/Widgets/Cover.dart';

class ItemsTab extends StatefulWidget {
  final String endpoint;
  ItemsTab(this.endpoint);
  @override
  _ItemsTabState createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab>
    with AutomaticKeepAliveClientMixin {
  // ScrollController _scrollController;
  Future<List<SearchResult>>? results;

  @override
  void initState() {
    // _scrollController = new ScrollController(
    //   initialScrollOffset: 0.0,
    //   keepScrollOffset: true,
    // );
    super.initState();
    results = _getData();
  }

  @override
  void dispose() {
    // _scrollController.dispose();
    super.dispose();
  }

  Future<List<SearchResult>> _getData() {
    return FtpbdService().search(widget.endpoint, limit: 24);
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

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: FutureBuilder<List<SearchResult>>(
        future: results,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              return _buildGridView(context, snapshot.data!);
            } else if (snapshot.hasError)
              return Center(
                child: buildError(
                  snapshot.error?.toString() ?? "Error occurred",
                  onRefresh: () => setState(() {}),
                ),
              );
            else
              return Container();
          } else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<SearchResult> values) {
    return OrientationBuilder(
      builder: (context, orientation) {
        int itemCount = orientation == Orientation.landscape ? 6 : 3;
        return GridView.builder(
          // controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: itemCount,
            childAspectRatio: 0.55,
          ),
          itemCount: values.length,

          itemBuilder: (BuildContext context, int index) {
            SearchResult item = values[index];
            return Cover(
              searchResult: item,
              showIcon: false,
              onTap: () {
                Navigator.pushNamed(context, "/detail", arguments: item);
              },
              // onFocus: () {_toEnd(index, 4);}
            );
          },
        );
      },
    );
  }
}
