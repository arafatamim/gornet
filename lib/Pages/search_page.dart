import 'dart:async';
import 'dart:io';

import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Widgets/cover.dart';
import 'package:goribernetflix/Widgets/error.dart';
import 'package:goribernetflix/Widgets/virtual_keyboard/virtual_keyboard.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:goribernetflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SearchStore extends ChangeNotifier {
  // Give us ADTs!!
  Deferred<List<SearchResult>> response = Deferred.idle();

  void getItems(BuildContext context, String query) async {
    try {
      response = Deferred.inProgress();
      notifyListeners();
      final results = await Provider.of<FtpbdService>(
        context,
        listen: false,
      ).multiSearch(query: query);
      response = Deferred.success(results);
    } catch (e, s) {
      response = Deferred.error(e, s);
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
        body: SafeArea(
          child: ChangeNotifierProvider(
            create: (context) => SearchStore(),
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
      ),
    );
  }

  Container _buildMobileLayout() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Consumer<SearchStore>(
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
            child: Consumer<SearchStore>(builder: _buildSearchResults),
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
                    child: Consumer<SearchStore>(
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
              child: Consumer<SearchStore>(builder: _buildSearchResults),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchStore store, _) {
    return store.response.where<Widget>(
      onSuccess: (results) {
        if (results.isEmpty) {
          return const Center(child: ErrorMessage("No results found"));
        }
        return CoverListView(
          results,
          showIcon: true,
        );
      },
      onError: (error, _) => Center(child: ErrorMessage(error)),
      onInProgress: () => const Center(child: CircularProgressIndicator()),
      onIdle: () => const SizedBox.shrink(),
    );
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
      style: Theme.of(context).textTheme.bodyText2?.copyWith(
            color: Colors.white,
            fontSize: 32.0,
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
        hintStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
              fontSize: 32,
              color: Colors.grey,
            ),
      ),
    );
  }
}
