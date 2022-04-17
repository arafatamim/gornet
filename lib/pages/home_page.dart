import 'package:flutter/services.dart';
import 'package:goribernetflix/freezed/result_endpoint.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/section.dart';
import 'package:goribernetflix/models/user.dart';
import 'package:goribernetflix/services/api.dart';
import 'package:goribernetflix/services/favorites.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:goribernetflix/tabs/home_tab.dart';
import 'package:goribernetflix/tabs/items_tab.dart';
import 'package:goribernetflix/widgets/buttons/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/scaffold_with_button.dart';
import 'package:provider/provider.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _controller;
  User? user;
  bool isTraktActivated = false;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setValues();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 720;
    isWide
        ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)
        : SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return ScaffoldWithButton(
      appBar: isWide ? null : _buildAppbar(context),
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.primary,
              ],
              stops: [0, 1],
              center: Alignment.bottomCenter,
              radius: 1.4,
              focal: const Alignment(0, 2.5),
            ),
          ),
          child: Column(
            children: [
              // Nav bar
              if (isWide) _buildNavBar(context),

              // Main view
              Expanded(
                child: Container(
                  clipBehavior: Clip.none,
                  margin: EdgeInsets.symmetric(
                    horizontal: isWide ? 64 : 0,
                  ),
                  child: TabBarView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      HomeTab(key: UniqueKey()),
                      user != null
                          ? ItemsTab(
                              sections: [
                                Section(
                                  itemFetcher:
                                      Provider.of<FavoritesService>(context)
                                          .getFavorites(user!.id),
                                ),
                                if (isTraktActivated)
                                  Section(
                                    title: "Movies to watch",
                                    itemFetcher:
                                        Provider.of<UserService>(context)
                                            .getTraktWatchlist(user!.id)
                                            .then((value) =>
                                                value.take(6).toList()),
                                  ),
                              ],
                              showIcon: true,
                            )
                          : const Center(
                              child: ErrorMessage(
                                  "Select a profile to view watchlist here"),
                            ),
                      ItemsTab(
                        sections: [
                          Section(
                            itemFetcher:
                                Provider.of<FtpbdService>(context).search(
                              ResultEndpoint.discover(MediaType.movie),
                            ),
                          ),
                        ],
                      ),
                      ItemsTab(
                        sections: [
                          Section(
                            itemFetcher:
                                Provider.of<FtpbdService>(context).search(
                              ResultEndpoint.discover(MediaType.series),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      elevation: 7,
      title: Text(
        widget.title,
        style: GoogleFonts.gloriaHallelujah(fontSize: 20.0),
      ),
      automaticallyImplyLeading: false,
      bottom: TabBar(
        indicatorColor: Theme.of(context).colorScheme.secondary,
        controller: _controller,
        tabs: <Widget>[
          const Tab(
            icon: Icon(FeatherIcons.home),
            text: "Home",
          ),
          const Tab(
            icon: Icon(FeatherIcons.heart),
            text: "My list",
          ),
          const Tab(
            icon: Icon(FeatherIcons.film),
            text: "Movies",
          ),
          const Tab(
            icon: Icon(FeatherIcons.tv),
            text: "Shows",
          )
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, "/search");
          },
          icon: const Icon(FeatherIcons.search),
        ),
        PopupMenuButton<String>(
          itemBuilder: (context) {
            return {"Reload", "Settings"}
                .map((e) => PopupMenuItem(value: e, child: Text(e)))
                .toList();
          },
          onSelected: (value) {
            switch (value) {
              case "Reload":
                setState(() {});
                break;
              case "Settings":
                Navigator.pushNamed(context, "/settings");
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 10),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedIconButton(
            autofocus: true,
            icon: const Icon(FeatherIcons.search),
            label: Text(
              "Search",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/search");
            },
          ),
          const SizedBox(width: 16),
          GNav(
            key: ValueKey(_controller.index),
            selectedIndex: _controller.index,
            onTabChange: (value) {
              _controller.animateTo(value);
            },
            gap: 8,
            color: Colors.white.withAlpha(100),
            activeColor: Colors.grey.shade200,
            iconSize: 32,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            tabs: [
              GButton(
                textStyle: Theme.of(context).textTheme.bodyText1,
                icon: FeatherIcons.home,
                text: "Home",
              ),
              GButton(
                textStyle: Theme.of(context).textTheme.bodyText1,
                icon: FeatherIcons.heart,
                text: "My list",
              ),
              GButton(
                textStyle: Theme.of(context).textTheme.bodyText1,
                icon: FeatherIcons.film,
                text: "Movies",
              ),
              GButton(
                textStyle: Theme.of(context).textTheme.bodyText1,
                icon: FeatherIcons.tv,
                text: "Shows",
              ),
            ],
          ),
          const Spacer(),
          AnimatedIconButton(
            icon: const Icon(FeatherIcons.refreshCw),
            label: Text(
              "Refresh",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onPressed: () {
              setState(() {});
            },
          ),
          const SizedBox(width: 16),
          FutureBuilder2<User?>(
            future: Provider.of<UserService>(context).getCurrentUser(),
            builder: (context, response) => response.maybeWhen(
              // add a child to fuurebuilder
              success: (user) {
                if (user == null) {
                  return AnimatedIconButton(
                    icon: const Icon(FeatherIcons.settings),
                    label: Text(
                      "Settings",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamed("/settings"),
                  );
                }
                return AnimatedIconButton(
                  icon: const Icon(FeatherIcons.user),
                  label: Text(
                    user.username,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onPressed: () => Navigator.of(context).pushNamed("/settings"),
                );
              },
              orElse: () => AnimatedIconButton(
                icon: const Icon(FeatherIcons.userX),
                label: Text(
                  "Settings",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onPressed: () => Navigator.of(context).pushNamed("/settings"),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.title,
            style: GoogleFonts.gloriaHallelujah(fontSize: 24.0),
          ),
        ],
      ),
    );
  }

  Future<void> _setValues() async {
    final user =
        await Provider.of<UserService>(context, listen: false).getCurrentUser();
    if (user != null) {
      final isTraktActivated =
          await Provider.of<UserService>(context, listen: false)
              .isTraktActivated(user.id);

      setState(() {
        this.user = user;
        this.isTraktActivated = isTraktActivated;
      });
    }
  }
}
