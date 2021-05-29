import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:flutter/material.dart';

import 'package:chillyflix/Widgets/Cover.dart';
import 'package:provider/provider.dart';

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
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.only(left: 16),
              child: Align(
                child: Text(
                  'Recent movies',
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      ?.apply(fontSizeFactor: 0.7, color: Colors.grey.shade300),
                ),
                alignment: Alignment.topLeft,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 450),
              child: CoverListViewBuilder(
                results: Provider.of<FtpbdService>(context).search(
                  "movie",
                  limit: 10,
                ),
                separator: false,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.only(left: 16),
              child: Align(
                child: Text(
                  'Recent series uploads',
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      ?.apply(fontSizeFactor: 0.7, color: Colors.grey.shade300),
                ),
                alignment: Alignment.topLeft,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 450),
              child: CoverListViewBuilder(
                results: Provider.of<FtpbdService>(context).search(
                  "series",
                  limit: 10,
                ),
                separator: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
