import 'dart:math';

import 'package:deferred_type/deferred_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/user.dart';
import 'package:goribernetflix/result_endpoint.dart';
import 'package:goribernetflix/services/api.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:goribernetflix/widgets/cover.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/shimmers.dart';
import 'package:goribernetflix/widgets/spotlight.dart';

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
    final isWide = MediaQuery.of(context).size.width > 720;

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: Builder(
              builder: (context) {
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
                  /* For All Mankind */ "87917",
                ];
                final random = Random();
                return FutureBuilder2<Series>(
                  future: Provider.of<FtpbdService>(context).getSeries(
                    seriesList[random.nextInt(seriesList.length)],
                  ),
                  builder: (context, result) => result.where(
                    onInProgress: () => const ShimmerItem(
                      child: SpotlightShimmer(),
                    ),
                    onSuccess: (item) {
                      return Spotlight(
                        title: item.title ?? "Unknown Title",
                        backdrop:
                            item.imageUris?.thumb ?? item.imageUris?.backdrop,
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
                        },
                      );
                    },
                    onError: (error, stackTrace) => ErrorMessage(error),
                    orElse: () => const SizedBox.shrink(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          Section(
            title: "Trending this week",
            fetcher: Provider.of<FtpbdService>(context).search(
              ResultEndpoint.discover(MediaType.movie),
            ),
          ),
          const SizedBox(height: 40),
          Section(
            title: "Airing on Disney+",
            fetcher: Provider.of<FtpbdService>(context).search(
                ResultEndpoint.discover(MediaType.series, networks: ["2739"])),
          ),
          const SizedBox(height: 40),
          Section(
            title: "Apple TV+ Originals",
            fetcher: Provider.of<FtpbdService>(context).search(
              ResultEndpoint.discover(MediaType.series, networks: ["2552"]),
            ),
          ),
        ],
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final Future<List<SearchResult>> fetcher;

  const Section({
    Key? key,
    required this.title,
    required this.fetcher,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _buildSectionTitle(title),
          LimitedBox(
            maxHeight: 450,
            child: CoverListViewBuilder(
              results: fetcher,
              separator: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(builder: (context) {
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
    });
  }
}
