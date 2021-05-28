import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:chillyflix/Services/StorageService.dart';
import 'package:chillyflix/Tabs/HomeTab.dart';
import 'package:chillyflix/Tabs/ItemsTab.dart';
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
  late TabController _controller;

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
        .getFavorites(MediaType.Series)
        .then((value) => value
            ?.map((e) => FtpbdService.mapIdToSearchResult(MediaType.Series, e))
            .toList());
    return Future.wait(strings ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
        title: Row(
          children: <Widget>[
            Text(
              widget.title,
              style: GoogleFonts.gloriaHallelujah(fontSize: 24.0),
            ),
            SizedBox(width: 30),
            GNav(
                onTabChange: (value) {
                  _controller.animateTo(value);
                },
                gap: 8,
                color: Colors.white.withAlpha(100),
                activeColor: Colors.grey.shade200,
                iconSize: 32,
                padding: const EdgeInsets.all(16),
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
                    text: "Favorites",
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
                ])
            // TabBar(
            //   controller: _controller,
            //   physics: NeverScrollableScrollPhysics(),
            //   indicator: UnderlineTabIndicator(
            //     borderSide: BorderSide(
            //       width: 4,
            //       color: Theme.of(context).colorScheme.secondary,
            //     ),
            //   ),
            //   labelStyle: GoogleFonts.sourceSansPro(fontSize: 20.0),
            //   overlayColor: MaterialStateProperty.resolveWith((states) {
            //     const Set<MaterialState> interactiveStates = {
            //       MaterialState.pressed,
            //       MaterialState.hovered,
            //       MaterialState.focused,
            //     };
            //     if (states.any(interactiveStates.contains)) {
            //       return Colors.white.withAlpha(60);
            //     }
            //     return Colors.teal;
            //   }),
            //   labelColor: Colors.white,
            //   unselectedLabelColor: Colors.grey.shade400,
            //   isScrollable: true,
            //   tabs: <Widget>[
            //     Tab(text: 'Home', icon: Icon(Icons.home)),
            //     Tab(text: 'Favorites', icon: Icon(Icons.favorite_rounded)),
            //     Tab(text: 'Movies', icon: Icon(Icons.movie)),
            //     Tab(text: 'Shows', icon: Icon(Icons.tv)),
            //   ],
            // ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(FeatherIcons.search),
            focusColor: Colors.white.withAlpha(100),
            onPressed: () {
              Navigator.pushNamed(context, "/search");
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          HomeTab(),
          ItemsTab(
            future: _getFavs(),
            showIcon: true,
          ),
          ItemsTab(
            future: Provider.of<FtpbdService>(context).search(
              "movie",
              limit: 24,
            ),
          ),
          ItemsTab(
            future: Provider.of<FtpbdService>(context).search(
              "series",
              limit: 24,
            ),
          ),
        ],
      ),
    );
  }
}
