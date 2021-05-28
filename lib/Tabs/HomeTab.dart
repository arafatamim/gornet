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
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
                        ?.apply(color: Theme.of(context).colorScheme.secondary),
                  ),
                  alignment: Alignment.topLeft,
                ),
              ),
              CoverListView(
                results: Provider.of<FtpbdService>(context).search(
                  "movie",
                  limit: 6,
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
                        ?.apply(color: Theme.of(context).colorScheme.secondary),
                  ),
                  alignment: Alignment.topLeft,
                ),
              ),
              CoverListView(
                results: Provider.of<FtpbdService>(context).search(
                  "series",
                  limit: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
