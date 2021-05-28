import 'dart:async';
import 'dart:io';

import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:chillyflix/Widgets/Cover.dart';
import 'package:chillyflix/Widgets/RoundedCard.dart';
import 'package:chillyflix/Widgets/virtual_keyboard/virtual_keyboard.dart';
import 'package:chillyflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
        node.previousFocus();
      } else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp)
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
      final futures = [
        FtpbdService().search("movie", query: query, limit: 4),
        FtpbdService().search("series", query: query, limit: 4)
      ];
      final results = await Future.wait(futures).then(
        (event) => event.expand((element) => element).toList(),
      );
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
                            // focusNode: _focusNode,
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
                          onChanged: (value) {
                            if (_debounce?.isActive ?? false)
                              _debounce?.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 750),
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
                  child: StreamBuilder<List<SearchResult>>(
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
    AsyncSnapshot<List<SearchResult>> snapshot,
  ) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Container();
      case ConnectionState.none:
      case ConnectionState.active:
      case ConnectionState.done:
        if (snapshot.hasData && snapshot.data!.length > 0) {
          return _buildResultsList(context, snapshot.data!);
        } else if (snapshot.hasError) {
          return Center(
            child: buildError(
              snapshot.error?.toString() ?? "Error searching",
              onRefresh: () => setState(() {}),
            ),
          );
        } else {
          return Center(
            child: buildError("No results found"),
          );
        }
    }
  }

  Widget _buildResultsList(BuildContext context, List<SearchResult> values) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: values.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        SearchResult item = values[index];
        return AspectRatio(
          aspectRatio: 0.5,
          child: Cover(
            searchResult: item,
            showIcon: true,
            style: RoundedCardStyle(
              primaryColor: Colors.transparent,
              textColor: Colors.grey.shade400,
              focusTextColor: Colors.white,
              mutedTextColor: Colors.grey.shade600,
              focusMutedTextColor: Colors.grey.shade300,
            ),
            onTap: () {
              Navigator.pushNamed(context, "/detail", arguments: item);
            },
          ),
        );
      },
    );
  }
}

bool _isUtf16Surrogate(int value) {
  return value & 0xF800 == 0xD800;
}
