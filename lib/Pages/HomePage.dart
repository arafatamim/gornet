import 'package:chillyflix/Models/models.dart';
import 'package:chillyflix/Services/api.dart';
import 'package:chillyflix/Services/favorites.dart';
import 'package:chillyflix/Tabs/HomeTab.dart';
import 'package:chillyflix/Tabs/ItemsTab.dart';
import 'package:chillyflix/Widgets/buttons/animated_icon_button.dart';
import 'package:chillyflix/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<SearchResult>> _getFavs() async {
    final strings = await Provider.of<FavoritesService>(context, listen: false)
        .getFavorites()
        .then((value) => value
            .map(
              (e) => mapIdToSearchResult(
                MediaType.Series,
                e,
                service: Provider.of<FtpbdService>(context, listen: false),
              ),
            )
            .toList());
    return Future.wait(strings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusTraversalGroup(
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
              focal: Alignment(0, 2.5),
            ),
          ),
          child: Column(
            children: [
              // Nav bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 10),
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AnimatedIconButton(
                      autofocus: true,
                      icon: Icon(FeatherIcons.search),
                      label: Text(
                        "Search",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/search");
                      },
                    ),
                    SizedBox(width: 16),
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
                    Spacer(),
                    AnimatedIconButton(
                      icon: Icon(FeatherIcons.refreshCw),
                      label: Text(
                        "Refresh",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 16),
                    Text(
                      widget.title,
                      style: GoogleFonts.gloriaHallelujah(fontSize: 24.0),
                    ),
                  ],
                ),
              ),
              // Main view
              Expanded(
                child: Container(
                  clipBehavior: Clip.none,
                  margin: const EdgeInsets.symmetric(horizontal: 64),
                  child: TabBarView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      HomeTab(),
                      ItemsTab(
                        future: _getFavs(),
                        showIcon: true,
                      ),
                      ItemsTab(
                        future: Provider.of<FtpbdService>(context).search(
                          "movie",
                          "latest",
                          limit: 24,
                        ),
                      ),
                      ItemsTab(
                        future: Provider.of<FtpbdService>(context).search(
                          "series",
                          "latest",
                          limit: 24,
                        ),
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
}

        // appBar: AppBar(
        //   toolbarHeight: 80,
        //   flexibleSpace: Container(
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //           colors: [
        //             Theme.of(context).colorScheme.primary,
        //             Theme.of(context).colorScheme.secondary,
        //           ],
        //           begin: const FractionalOffset(0.0, 0.0),
        //           end: const FractionalOffset(1.0, 0.0),
        //           stops: [0.0, 1.0],
        //           tileMode: TileMode.clamp),
        //     ),
        //   ),
        //   title: Row(
        //     children: <Widget>[
        //       Text(
        //         widget.title,
        //         style: GoogleFonts.gloriaHallelujah(fontSize: 24.0),
        //       ),
        //       SizedBox(width: 30),
        //       GNav(
        //           onTabChange: (value) {
        //             _controller.animateTo(value);
        //           },
        //           gap: 8,
        //           color: Colors.white.withAlpha(100),
        //           activeColor: Colors.grey.shade200,
        //           iconSize: 32,
        //           padding: const EdgeInsets.all(16),
        //           duration: const Duration(milliseconds: 200),
        //           curve: Curves.easeInOutCubic,
        //           tabs: [
        //             GButton(
        //               textStyle: Theme.of(context).textTheme.bodyText1,
        //               icon: FeatherIcons.home,
        //               text: "Home",
        //             ),
        //             GButton(
        //               textStyle: Theme.of(context).textTheme.bodyText1,
        //               icon: FeatherIcons.heart,
        //               text: "Favorites",
        //             ),
        //             GButton(
        //               textStyle: Theme.of(context).textTheme.bodyText1,
        //               icon: FeatherIcons.film,
        //               text: "Movies",
        //             ),
        //             GButton(
        //               textStyle: Theme.of(context).textTheme.bodyText1,
        //               icon: FeatherIcons.tv,
        //               text: "Shows",
        //             ),
        //           ])
        //       // TabBar(
        //       //   controller: _controller,
        //       //   physics: NeverScrollableScrollPhysics(),
        //       //   indicator: UnderlineTabIndicator(
        //       //     borderSide: BorderSide(
        //       //       width: 4,
        //       //       color: Theme.of(context).colorScheme.secondary,
        //       //     ),
        //       //   ),
        //       //   labelStyle: GoogleFonts.sourceSansPro(fontSize: 20.0),
        //       //   overlayColor: MaterialStateProperty.resolveWith((states) {
        //       //     const Set<MaterialState> interactiveStates = {
        //       //       MaterialState.pressed,
        //       //       MaterialState.hovered,
        //       //       MaterialState.focused,
        //       //     };
        //       //     if (states.any(interactiveStates.contains)) {
        //       //       return Colors.white.withAlpha(60);
        //       //     }
        //       //     return Colors.teal;
        //       //   }),
        //       //   labelColor: Colors.white,
        //       //   unselectedLabelColor: Colors.grey.shade400,
        //       //   isScrollable: true,
        //       //   tabs: <Widget>[
        //       //     Tab(text: 'Home', icon: Icon(Icons.home)),
        //       //     Tab(text: 'Favorites', icon: Icon(Icons.favorite_rounded)),
        //       //     Tab(text: 'Movies', icon: Icon(Icons.movie)),
        //       //     Tab(text: 'Shows', icon: Icon(Icons.tv)),
        //       //   ],
        //       // ),
        //     ],
        //   ),
        //   actions: <Widget>[
        //     IconButton(
        //       icon: Icon(FeatherIcons.search),
        //       focusColor: Colors.white.withAlpha(100),
        //       onPressed: () {
        //         Navigator.pushNamed(context, "/search");
        //       },
        //     ),
        //   ],
        // ),