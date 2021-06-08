import 'dart:math';

import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Pages/HomePage.dart';
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
  late final ScrollController _controller;

  bool get wantKeepAlive => true;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 40),
          _buildSectionTitle("Top Picks"),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: Consumer<FtpbdService>(
                child: ShimmerItem(child: SpotlightShimmer()),
                builder: (context, service, shimmer) {
                  final seriesList = [
                    /* Expanse */ "361912",
                    /* B99 */ "362461",
                    /* Angie Tribeca */ "361693",
                    /* Good Place */ "361264",
                    /* Ted Lasso */ "362077",
                    /* Space Force */ "361049",
                  ];
                  final random = new Random();
                  // final series = value.getSeries("361693");
                  final series = service
                      .getSeries(seriesList[random.nextInt(seriesList.length)]);
                  return FutureBuilder<Series>(
                    future: series,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return shimmer!;
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
                                ageRating: item.ageRating,
                                endDate: item.endDate,
                                hasEnded: item.hasEnded,
                                rating: item.criticRatings?.community,
                                runtime: item.averageRuntime,
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
              controller: _controller,
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
