import 'dart:async';
import 'dart:io';

import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/freezed/detail_arguments.dart';
import 'package:goribernetflix/freezed/result_endpoint.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/person.dart';
import 'package:goribernetflix/services/api.dart';
import 'package:goribernetflix/widgets/buttons/responsive_button.dart';
import 'package:goribernetflix/widgets/cover.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/tabs/gn_tab_bar.dart';
import 'package:goribernetflix/widgets/virtual_keyboard/virtual_keyboard.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:goribernetflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SearchStore extends ChangeNotifier {
  // Give us ADTs!!
  Deferred<List<SearchResult>> media = Deferred.idle();
  Deferred<List<PersonResult>> people = Deferred.idle();

  void searchMedia(BuildContext context, String query) async {
    try {
      media = Deferred.inProgress();
      notifyListeners();
      final results = await Provider.of<FtpbdService>(
        context,
        listen: false,
      ).search(ResultEndpoint.multiSearch(query));
      media = Deferred.success(results);
    } catch (e, s) {
      media = Deferred.error(e, s);
    } finally {
      notifyListeners();
    }
  }

  void searchPerson(BuildContext context, String query) async {
    try {
      people = Deferred.inProgress();
      notifyListeners();
      final results = await Provider.of<FtpbdService>(
        context,
        listen: false,
      ).searchPerson(query);
      people = Deferred.success(results);
    } catch (e, s) {
      people = Deferred.error(e, s);
    } finally {
      notifyListeners();
    }
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  late final TabController _tabController;
  late final SearchStore _searchStore;
  Timer? _debounce;

  String get query => _textController.text;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _searchStore = SearchStore();

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    _searchStore.dispose();
    _debounce?.cancel();
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
            create: (context) => _searchStore,
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
                  store.searchMedia(context, _textController.text);
                }
              },
            ),
          ),
          const SizedBox(height: 25),
          // Expanded(
          //   flex: 2,
          //   child: _buildSearchResults(store.),
          // )
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
                  // left side
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // search box
                        Expanded(
                          child: FocusScope(
                            canRequestFocus: false,
                            child: SearchWidget(
                              controller: _textController,
                              readOnly: true,
                            ),
                          ),
                        ),
                        GNTabBar(
                          onTabChange: (index) {
                            if (index == 0) {
                              _searchStore.searchMedia(context, query);
                            } else if (index == 1) {
                              _searchStore.searchPerson(context, query);
                            }
                          },
                          controller: _tabController,
                          color: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.focused)
                                ? Colors.white
                                : Colors.black.withAlpha(60),
                          ),
                          mainAxisAlignment: MainAxisAlignment.center,
                          tabs: [
                            const ResponsiveButton(label: "Movies & Series"),
                            const ResponsiveButton(label: "Cast & Crew"),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Textbox
                  const SizedBox(width: 25),
                  // Keyboard
                  Expanded(
                    child: VirtualKeyboard(
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
                              switch (_tabController.index) {
                                case 0:
                                  _searchStore.searchMedia(context, query);
                                  break;
                                case 1:
                                  _searchStore.searchPerson(context, query);
                                  break;
                              }
                            }
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  Consumer<SearchStore>(
                    builder: (context, store, child) =>
                        _buildSearchResults(store.media),
                  ),
                  Consumer<SearchStore>(
                    builder: (context, store, child) =>
                        _buildPersonResults(store.people),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(Deferred<List<SearchResult>> media) {
    return media.where<Widget>(
      onSuccess: (results) {
        if (results.isEmpty) {
          return const Center(child: ErrorMessage("No results found"));
        }
        return CoverListView(
          [
            for (final item in results)
              Cover(
                title: item.name,
                subtitle: item.year?.toString(),
                icon: item.isMovie ? FeatherIcons.film : FeatherIcons.tv,
                image: item.imageUris?.primary,
                key: ValueKey(item.id),
                onTap: () {
                  Navigator.pushNamed(context, "/detail",
                      arguments: DetailArgs.media(item));
                },
              )
          ],
          showIcon: true,
        );
      },
      onError: (error, _) => Center(child: ErrorMessage(error)),
      onInProgress: () => const Center(child: CircularProgressIndicator()),
      onIdle: () => const SizedBox.shrink(),
    );
  }

  Widget _buildPersonResults(Deferred<List<PersonResult>> people) {
    return people.where<Widget>(
      onSuccess: (results) {
        if (results.isEmpty) {
          return const Center(child: ErrorMessage("No results found"));
        }
        return CoverListView(
          [
            for (final item in results)
              Cover(
                title: item.name,
                subtitle: item.department,
                icon: FeatherIcons.user,
                key: ValueKey(item.id),
                image: item.imageUris.primary,
                onTap: () {
                  Navigator.pushNamed(context, "/detail",
                      arguments: DetailArgs.person(item));
                },
              )
          ],
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
