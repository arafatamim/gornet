import 'package:flutter/material.dart';

import 'package:chillyflix/Widgets/Cover.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key? key}) : super(key: key);
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
                child: Text(
                  'Recent movies',
                  style: GoogleFonts.oswald(color: Colors.white, fontSize: 30),
                ),
                alignment: Alignment.topLeft),
          ),
          SizedBox(height: 20),
          coverListView(
            context,
            'movie',
            onRefresh: () => setState(() {}),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Align(
              child: Text(
                'Recent series uploads',
                style: GoogleFonts.oswald(color: Colors.white, fontSize: 30),
              ),
              alignment: Alignment.topLeft,
            ),
          ),
          coverListView(
            context,
            'series',
            onRefresh: () => setState(() {}),
          ),
        ],
      ),
    );
  }
}
