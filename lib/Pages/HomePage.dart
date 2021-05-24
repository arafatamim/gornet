import 'package:chillyflix/Tabs/HomeTab.dart';
import 'package:chillyflix/Tabs/ItemsTab.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.transparent,
          // elevation: 6,
          toolbarHeight: 84,
          bottomOpacity: 0.0,
          title: Row(
            children: <Widget>[
              Text(
                widget.title,
                style: GoogleFonts.gloriaHallelujah(fontSize: 24.0),
              ),
              SizedBox(width: 50),
              TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                labelStyle: GoogleFonts.sourceSansPro(fontSize: 20.0),
                overlayColor: MaterialStateProperty.resolveWith((states) {
                  const Set<MaterialState> interactiveStates = {
                    MaterialState.pressed,
                    MaterialState.hovered,
                    MaterialState.focused,
                  };
                  if (states.any(interactiveStates.contains)) {
                    return Colors.white.withAlpha(100);
                  }
                  return Colors.teal;
                }),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                isScrollable: true,
                // indicatorColor: Color.fromARGB(255, 255, 60, 70),
                tabs: <Widget>[
                  Tab(text: 'Home', icon: Icon(Icons.home)),
                  Tab(text: 'Movies', icon: Icon(Icons.movie)),
                  Tab(text: 'Shows', icon: Icon(Icons.tv)),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              focusColor: Colors.white.withAlpha(100),
              onPressed: () {
                Navigator.pushNamed(context, "/search");
              },
            ),
          ],
        ),
        body: Center(
          child: TabBarView(
            children: <Widget>[
              HomeTab(),
              ItemsTab("movie"),
              ItemsTab("series"),
            ],
          ),
        ),
      ),
    );
  }
}
