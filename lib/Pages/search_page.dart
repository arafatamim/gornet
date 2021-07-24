import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Widgets/cover.dart';
import 'package:goribernetflix/Widgets/virtual_keyboard/virtual_keyboard.dart';
import 'package:goribernetflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchModel extends ChangeNotifier {
  bool _hasNotStartedYet = true;
  bool _loading = false;
  Object? _error;
  List<SearchResult> _results = [];

  UnmodifiableListView<SearchResult> get results =>
      UnmodifiableListView(_results);
  bool get isLoading => _loading;
  Object? get error => _error;
  bool get isNotStartedYet => _hasNotStartedYet;

  void getItems(BuildContext context, String query) async {
    try {
      _hasNotStartedYet = false;
      _loading = true;
      _error = null;
      final results = await Provider.of<FtpbdService>(context, listen: false)
          .multiSearch(query: query);
      _results = results;
      _loading = false;
    } catch (e) {
      _error = e;
    } finally {
      notifyListeners();
    }
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _textController = TextEditingController();
  late FocusNode _focusNode;
  // final StreamController<List<SearchResult>?> _resultsStream =
  //     StreamController<List<SearchResult>?>();
  Timer? _debounce;

  @override
  void initState() {
    _focusNode = FocusNode();

    _focusNode.onKey = (node, keyEvent) {
      if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
        node.previousFocus();
      } else if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp) {
        node.nextFocus();
      }
      return KeyEventResult.ignored;
    };
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    // _resultsStream.close();
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  // void _getItems(String query) async {
  //   try {
  //     _resultsStream.add(null);
  //     final results = await Provider.of<FtpbdService>(context, listen: false)
  //         .multiSearch(query: query);
  //     _resultsStream.add(results);
  //   } catch (e) {
  //     _resultsStream.addError(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
      },
      child: Scaffold(
        floatingActionButton: coalesceException(
          () => Platform.isLinux
              ? FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back),
                )
              : null,
          null,
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniStartFloat,
        body: ChangeNotifierProvider(
          create: (context) => SearchModel(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 720) {
                return _buildWideLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  Container _buildMobileLayout() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Consumer<SearchModel>(
            builder: (context, store, child) => SearchWidget(
              controller: _textController,
              onSubmitted: (value) {
                if (_textController.text.trim() != "") {
                  store.getItems(context, _textController.text);
                }
              },
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            flex: 2,
            child: Consumer<SearchModel>(builder: _buildSearchResults),
          )
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Container(
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
                      child: SearchWidget(
                        controller: _textController,
                        readOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Consumer<SearchModel>(
                      builder: (context, store, child) => VirtualKeyboard(
                        controller: _textController,
                        keyboardHeight: 185,
                        textTransformer: (incomingValue) =>
                            incomingValue?.toLowerCase(),
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) {
                            _debounce?.cancel();
                          }
                          _debounce = Timer(
                            const Duration(milliseconds: 2000),
                            () {
                              if (_textController.text.trim() != "") {
                                store.getItems(context, _textController.text);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Consumer<SearchModel>(builder: _buildSearchResults),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchModel model, _) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (model.error != null) {
      return Center(child: buildErrorBox(model.error));
    } else if (model.results.isNotEmpty) {
      return CoverListView(model.results, showIcon: true);
    } else if (!model.isNotStartedYet && model.results.isEmpty) {
      return Center(child: buildErrorBox("No results found"));
    } else {
      return const SizedBox.shrink();
    }

    // switch (snapshot.connectionState) {
    //   case ConnectionState.waiting:
    //     return Container();
    //   case ConnectionState.none:
    //   case ConnectionState.active:
    //   case ConnectionState.done:
    //     if (snapshot.data == null) {
    //       return const Center(child: CircularProgressIndicator());
    //     } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
    //       return CoverListView(snapshot.data!, showIcon: true);
    //     } else if (snapshot.hasError) {
    //       return Center(
    //         child: buildErrorBox(snapshot.error),
    //       );
    //     } else {
    //       return Center(
    //         child: buildErrorBox("No results found"),
    //       );
    //     }
    // }
  }
}

// bool _isUtf16Surrogate(int value) {
//   return value & 0xF800 == 0xD800;
// }

class SearchWidget extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onSubmitted;
  final bool readOnly;

  const SearchWidget({
    Key? key,
    this.onSubmitted,
    this.readOnly = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: readOnly,
      controller: controller,
      textInputAction: TextInputAction.go,
      textAlign: TextAlign.center,
      style: GoogleFonts.sourceSansPro(
        color: Colors.white,
        fontSize: 30.0,
      ),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        border: InputBorder.none,
        hintText: "Search...",
        hintStyle: GoogleFonts.sourceSansPro(
          color: Colors.grey,
        ),
      ),
    );
  }
}
