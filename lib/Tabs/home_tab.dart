import 'dart:math';

import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Models/user.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Services/user.dart';
import 'package:goribernetflix/Widgets/shimmers.dart';
import 'package:goribernetflix/Widgets/spotlight.dart';
import 'package:goribernetflix/future_adt.dart';
import 'package:goribernetflix/utils.dart';
import 'package:flutter/material.dart';

import 'package:goribernetflix/Widgets/cover.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  late final ScrollController _controller;

  @override
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
          FutureBuilder2<User?>(
            future: Provider.of<UserService>(context).getCurrentUser(),
            builder: (context, response) => response.where(
              onSuccess: (user) {
                if (user == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    Text(
                      "Welcome back, " + user.username,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(height: 10)
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: Consumer<FtpbdService>(
                child: const ShimmerItem(child: SpotlightShimmer()),
                builder: (context, service, shimmer) {
                  final seriesList = [
                    /* Expanse */ "63639",
                    /* B99 */ "48891",
                    /* Angie Tribeca */ "61969",
                    /* Good Place */ "66573",
                    /* Ted Lasso */ "97546",
                    /* Space Force */ "85922",
                    /* PnR */ "8592",
                    /* Mandalorian */ "82856",
                    /* Snowpiercer */ "79680",
                  ];
                  // final seriesList = [
                  //   /* Expanse */ "361912",
                  //   /* B99 */ "362461",
                  //   /* Angie Tribeca */ "361693",
                  //   /* Good Place */ "361264",
                  //   /* Ted Lasso */ "362077",
                  //   /* Space Force */ "361049",
                  // ];
                  final random = Random();
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
                                endDate: item.lastAired,
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
                                    ),
                                  );
                                });
                          } else {
                            return buildErrorBox(snapshot.error);
                          }
                        default:
                          return Container();
                      }
                    },
                  );
                }),
          ),
          const SizedBox(height: 40),
          _buildSectionTitle("Trending this week"),
          LimitedBox(
            maxHeight: 450,
            child: CoverListViewBuilder(
              results: Provider.of<FtpbdService>(context).search(
                "movie",
                "latest",
                limit: 10,
              ),
              separator: false,
              controller: _controller,
            ),
          ),
          const SizedBox(height: 40),
          _buildSectionTitle("Popular on TV"),
          LimitedBox(
            maxHeight: 450,
            child: CoverListViewBuilder(
              results: Provider.of<FtpbdService>(context).search(
                "series",
                "latest",
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
