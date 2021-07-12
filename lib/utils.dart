import 'dart:math' as Math;
import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

String formatBytes(int bytes, {int decimals = 1}) {
  if (bytes == 0) return "0 Bytes";
  final k = 1024;
  final sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  final i = (Math.log(bytes) / Math.log(k)).floor();
  final finalSize =
      (bytes / Math.pow(k, i)).toStringAsFixed(decimals.abs()); // 830.0
  return finalSize + " " + sizes[i];
}

Widget buildLabel(
  String label, {
  IconData? icon,
  String? imageAsset,
  bool hasBackground = false,
}) {
  return Container(
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: Colors.grey.shade300,
            size: 25,
          ),
          SizedBox(width: 10),
        ],
        if (imageAsset != null) ...[
          Image.asset(
            imageAsset,
            width: 30,
            height: 30,
          ),
          SizedBox(width: 10),
        ],
        Container(
          padding: hasBackground
              ? EdgeInsets.symmetric(horizontal: 10, vertical: 6)
              : null,
          decoration: hasBackground
              ? BoxDecoration(
                  color: Colors.grey.shade900.withAlpha(200),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Text(
            label,
            style: GoogleFonts.sourceSansPro(
              color:
                  hasBackground ? Colors.grey.shade300 : Colors.grey.shade200,
              fontSize: hasBackground ? 16 : 18,
            ),
          ),
        ),
        SizedBox(width: 30),
      ],
    ),
  );
}

// Widget buildError(String message, {VoidCallback? onRefresh}) {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Text(
//         message,
//         style: GoogleFonts.sourceSansPro(fontSize: 16),
//       ),
//       if (onRefresh != null)
//         TextButton.icon(
//           onPressed: onRefresh,
//           icon: Icon(FeatherIcons.refreshCcw),
//           label: Text("Refresh"),
//           style: ButtonStyle(
//             textStyle: MaterialStateProperty.all(
//               GoogleFonts.sourceSansPro(fontSize: 20),
//             ),
//           ),
//         )
//     ],
//   );
// }

Widget buildErrorBox(BuildContext context, Object? error) {
  return ConstrainedBox(
    constraints: BoxConstraints.tightFor(height: 110),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.frown,
              size: 28,
            ),
            SizedBox(height: 10),
            Text(
              error is DioError
                  ? error.message
                  : error is ServerError
                      ? error.message
                      : error is String
                          ? error
                          : "Unhandled error. Contact system administrator.",
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodyText1?.copyWith(height: 1.1),
            )
          ],
        ),
      ),
    ),
  );
}

T coalesceException<T>(T Function() func, T defaultValue) {
  try {
    return func();
  } catch (e) {
    print(e);
    return defaultValue;
  }
}

extension Converters on DateTime {
  String get longMonth {
    const Map<int, String> monthsInYear = {
      1: "january",
      2: "february",
      3: "march",
      4: "april",
      5: "may",
      6: "june",
      7: "july",
      8: "august",
      9: "september",
      10: "october",
      11: "november",
      12: "december"
    };
    return monthsInYear[this.month]!;
  }
}

extension CapExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${this.substring(1)}';
  String get capitalizeFirstOfEachWord =>
      this.split(" ").map((str) => str.capitalizeFirst).join(" ");
}

final cacheOptions = CacheOptions(
  store: MemCacheStore(), // TODO replace it
  policy: CachePolicy.request,
  // Optional. Returns a cached response on error but for statuses 401 & 403.
  hitCacheOnErrorExcept: [401, 403],
  // Optional. Overrides any HTTP directive to delete entry past this duration.
  maxStale: const Duration(days: 7),
  // Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
  // Default. Body and headers encryption with your own algorithm.
  cipher: null,
  // Default. Key builder to retrieve requests.
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  // Default. Allows to cache POST requests.
  // Overriding [keyBuilder] is strongly recommended.
  allowPostMethod: false,
);

Future<SearchResult> mapIdToSearchResult(
  MediaType mediaType,
  String id, {
  required FtpbdService service,
}) async {
  switch (mediaType) {
    case MediaType.Movie:
      final movie = await service.getMovie(id);
      final item = SearchResult(
        id: movie.id,
        name: movie.title ?? "",
        isMovie: true,
        imageUris: movie.imageUris,
      );
      return item;
    case MediaType.Series:
      final series = await service.getSeries(id);
      final item = SearchResult(
        id: series.id,
        name: series.title ?? "",
        isMovie: false,
        imageUris: series.imageUris,
      );
      return item;
  }
}

ServerError mapToServerError(dynamic e) {
  if (e is DioError) {
    if (e.response?.data != null) {
      return ServerError.fromJson(e.response!.data!);
    } else {
      return ServerError(message: e.message);
    }
  } else if (e is Exception) {
    return ServerError(message: e.toString());
  } else {
    return ServerError(
      message: "Unknown error. Contact administrator if problem persists.",
    );
  }
}
