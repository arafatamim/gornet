import 'dart:async';

import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Pages/DetailPage.dart';
import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:chillyflix/Widgets/Cover.dart';
import 'package:chillyflix/Widgets/virtual_keyboard/virtual_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchTab extends StatefulWidget {
  @override
  createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _textController = TextEditingController();
  late FocusNode _focusNode;
  StreamController<List<SearchResult>> _resultsStream =
      StreamController<List<SearchResult>>();
  Timer? _debounce;

  @override
  void initState() {
    _focusNode = FocusNode();

    _focusNode.onKey = (node, keyEvent) {
      if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
        node.unfocus();
      } else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp)
        node.unfocus();
      return KeyEventResult.ignored;
    };
    super.initState();
  }

  void dispose() {
    _textController.dispose();
    _resultsStream.close();
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _getItems(String query) async {
    try {
      final futures = [
        FtpbdService().search("movie", query: query, limit: 4),
        FtpbdService().search("series", query: query, limit: 4)
      ];
      final results = await Future.wait(futures)
          .then((event) => event.expand((element) => element).toList());
      _resultsStream.add(results);
    } catch (e) {
      _resultsStream.addError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              autofocus: true,
              readOnly: true,
              textInputAction: TextInputAction.go,
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSansPro(
                color: Colors.white,
                fontSize: 28.0,
              ),
              decoration: InputDecoration(
                fillColor: Colors.blueGrey.shade800,
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 48.0),
                ),
              ),
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 750), () {
                  if (val.trim() != "") _getItems(val);
                });
              },
            ),
            Text(_textController.text),
            Expanded(child: VirtualKeyboard()),
            Text("HEHEHE")
            // Expanded(
            //   child: StreamBuilder<List<SearchResult>>(
            //     stream: _resultsStream.stream,
            //     builder: _buildSearchResults,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
      BuildContext context, AsyncSnapshot<List<SearchResult>> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Center(
          child: Text(
            "Type something to start searching...",
            style: GoogleFonts.sourceSansPro(color: Colors.grey, fontSize: 20),
          ),
        );
      case ConnectionState.none:
      case ConnectionState.active:
      case ConnectionState.done:
        if (snapshot.hasData && snapshot.data!.length > 0) {
          return _buildGridView(context, snapshot.data!);
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: GoogleFonts.sourceSansPro(color: Colors.red),
            ),
          );
        } else {
          return Center(
            child: Text(
              "No results found",
              style:
                  GoogleFonts.sourceSansPro(color: Colors.grey, fontSize: 20),
            ),
          );
        }
    }
  }

  Widget _buildGridView(BuildContext context, List<SearchResult> values) {
    return OrientationBuilder(
      builder: (context, orientation) {
        int itemCount = orientation == Orientation.landscape ? 6 : 3;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: itemCount,
            childAspectRatio: 0.55,
          ),
          itemCount: values.length,
          itemBuilder: (BuildContext context, int index) {
            SearchResult item = values[index];
            return Cover(
              searchResult: item,
              showIcon: true,
              onTap: () {
                Navigator.pushNamed(context, "/details", arguments: item);
              },
            );
          },
        );
      },
    );
  }
}
