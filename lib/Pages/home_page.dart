import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Services/favorites.dart';
import 'package:goribernetflix/Tabs/home_tab.dart';
import 'package:goribernetflix/Tabs/items_tab.dart';
import 'package:goribernetflix/Widgets/buttons/animated_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

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

  // Future<List<SearchResult>> _getFavs() async {
  //   final strings = await Provider.of<FavoritesService>(context, listen: false)
  //       .getFavorites()
  //       .then((value) => value
  //           .map(
  //             (e) => mapIdToSearchResult(
  //               MediaType.Series,
  //               e,
  //               service: Provider.of<FtpbdService>(context, listen: false),
  //             ),
  //           )
  //           .toList());
  //   return Future.wait(strings);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width > 720
          ? null
          : AppBar(
              elevation: 7,
              title: Text(
                widget.title,
                style: GoogleFonts.gloriaHallelujah(fontSize: 20.0),
              ),
              bottom: TabBar(
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
                    setState(() {});
                  },
                  icon: const Icon(FeatherIcons.refreshCcw),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/search");
                  },
                  icon: const Icon(FeatherIcons.search),
                )
              ],
            ),
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
              focal: const Alignment(0, 2.5),
            ),
          ),
          child: Column(
            children: [
              // Nav bar
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 700) {
                    return _buildNavBar(context);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              // Main view
              Expanded(
                child: Container(
                  clipBehavior: Clip.none,
                  margin: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width > 700 ? 64 : 0,
                  ),
                  child: TabBarView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      const HomeTab(),
                      ItemsTab(
                        future: Provider.of<FavoritesService>(context)
                            .getFavorites(),
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
          Text(
            widget.title,
            style: GoogleFonts.gloriaHallelujah(fontSize: 24.0),
          ),
        ],
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
