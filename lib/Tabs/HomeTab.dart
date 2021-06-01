import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:chillyflix/Widgets/shimmers.dart';
import 'package:chillyflix/Widgets/spotlight.dart';
import 'package:chillyflix/utils.dart';
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

  late final ScrollController controller;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40),
            _buildSectionTitle("From Your List"),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: Consumer<FtpbdService>(builder: (context, value, _) {
                final r =
                    value.getSeries("361912"); // 361912 // 361871 // 450691
                return FutureBuilder<Series>(
                  future: r,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return ShimmerItem(
                          child: SpotlightShimmer(),
                        );
                      case ConnectionState.done:
                        if (snapshot.hasData) {
                          final item = snapshot.data!;
                          return Spotlight(
                              title: item.title ?? "Unknown Title",
                              backdrop: item.imageUris?.thumb ??
                                  item.imageUris?.backdrop,
                              logo: item.imageUris?.logo,
                              genres: item.genres,
                              synopsis: item.synopsis,
                              id: item.id,
                              year: item.year,
                              onTapDetails: () {
                                Navigator.pushNamed(
                                  context,
                                  "/detail",
                                  arguments: SearchResult(
                                    id: item.id,
                                    name: item.title ?? "",
                                    isMovie: false,
                                    imageUris: item.imageUris,
                                    year: item.year,
                                  ),
                                );
                              });
                        } else {
                          return buildError(snapshot.error.toString());
                        }
                      default:
                        return Container();
                    }
                  },
                );
              }),
            ),
            const SizedBox(height: 40),
            _buildSectionTitle("New Arrivals"),
            LimitedBox(
              maxHeight: 450,
              child: CoverListViewBuilder(
                results: Provider.of<FtpbdService>(context).search(
                  "movie",
                  limit: 10,
                ),
                separator: false,
                controller: controller,
              ),
            ),
            const SizedBox(height: 40),
            _buildSectionTitle("New Shows"),
            LimitedBox(
              maxHeight: 450,
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

  Container _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .headline2
            ?.apply(fontSizeFactor: 0.6, color: Colors.grey.shade300),
      ),
    );
  }
}
