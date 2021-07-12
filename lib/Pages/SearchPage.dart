import 'dart:async';
import 'dart:io';

import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Widgets/Cover.dart';
import 'package:goribernetflix/Widgets/virtual_keyboard/virtual_keyboard.dart';
import 'package:goribernetflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _textController = TextEditingController();
  late FocusNode _focusNode;
  StreamController<List<SearchResult>?> _resultsStream =
      StreamController<List<SearchResult>?>();
  Timer? _debounce;

  @override
  void initState() {
    _focusNode = FocusNode();

    _focusNode.onKey = (node, keyEvent) {
      if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown)
        node.previousFocus();
      else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp)
        node.nextFocus();
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
      _resultsStream.add(null);
      final results = await Provider.of<FtpbdService>(context, listen: false)
          .multiSearch(query: query);
      _resultsStream.add(results);
    } catch (e) {
      _resultsStream.addError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent()},
      child: Scaffold(
        floatingActionButton: coalesceException(
          () => Platform.isLinux
              ? FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Icon(Icons.arrow_back),
                )
              : null,
          null,
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniStartFloat,
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: FocusScope(
                          canRequestFocus: false,
                          child: TextField(
                            controller: _textController,
                            readOnly: true,
                            textInputAction: TextInputAction.go,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sourceSansPro(
                              color: Colors.white,
                              fontSize: 30.0,
                            ),
                            decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              border: InputBorder.none,
                              hintText: "Search...",
                              hintStyle: GoogleFonts.sourceSansPro(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 25),
                      Expanded(
                        child: VirtualKeyboard(
                          controller: _textController,
                          keyboardHeight: 185,
                          textTransformer: (incomingValue) =>
                              incomingValue?.toLowerCase(),
                          onChanged: (value) {
                            if (_debounce?.isActive ?? false)
                              _debounce?.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 2000),
                              () {
                                if (_textController.text.trim() != "")
                                  _getItems(_textController.text);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: StreamBuilder<List<SearchResult>?>(
                    stream: _resultsStream.stream,
                    builder: _buildSearchResults,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    AsyncSnapshot<List<SearchResult>?> snapshot,
  ) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Container();
      case ConnectionState.none:
      case ConnectionState.active:
      case ConnectionState.done:
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data!.length > 0) {
          return CoverListView(snapshot.data!, showIcon: true);
        } else if (snapshot.hasError) {
          return Center(
            child: buildErrorBox(context, snapshot.error),
          );
        } else {
          return Center(
            child: buildErrorBox(context, "No results found"),
          );
        }
    }
  }
}

// bool _isUtf16Surrogate(int value) {
//   return value & 0xF800 == 0xD800;
// }
