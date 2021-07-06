import 'dart:convert';

import 'package:chillyflix/Models/models.dart';
import "package:http/http.dart" as http;

extension ResponseOk on http.Response {
  bool get ok => this.statusCode >= 200 && this.statusCode < 300;
}

class StorageFormat {
  final String seriesId;
  final int seasonIndex;
  final int episodeIndex;

  StorageFormat({
    required final this.seriesId,
    required final this.seasonIndex,
    required final this.episodeIndex,
  });

  StorageFormat.fromJson(Map<String, dynamic> json)
      : seriesId = json["id"],
        seasonIndex = json["seasonIndex"],
        episodeIndex = json["episodeIndex"];

  Map<String, dynamic> toJson() => {
        "id": seriesId,
        "seasonIndex": seasonIndex,
        "episodeIndex": episodeIndex,
      };

  static List<StorageFormat> fromJsonArray(List<dynamic> json) =>
      json.map((e) => StorageFormat.fromJson(e)).toSet().toList();

  static List<Map<String, dynamic>> toJsonArray(List<StorageFormat> items) =>
      items.map((e) => e.toJson()).toSet().toList();

  @override
  String toString() {
    return "StorageFormat { seriesId: $seriesId; seasonIndex: $seasonIndex; episodeIndex: $episodeIndex }";
  }
}

class NextUpService {
  final String uri = "http://192.168.0.100:6767/api/user/nextup";

  // int? _getItemIndex(String seriesId, List<StorageFormat> items) {
  //   try {
  //     final index = items.indexWhere((element) => element.seriesId == seriesId);
  //     if (index < 0) {
  //       return null;
  //     } else
  //       return index;
  //   } on StateError {
  //     return null;
  //   }
  // }

  // List<StorageFormat> _updateOrAdd(
  //     StorageFormat item, List<StorageFormat> items) {
  //   final existingIndex = _getItemIndex(item.seriesId, items);
  //   if (existingIndex == null) {
  //     items.add(item);
  //     return items;
  //   } else {
  //     items[existingIndex] = item;
  //     return items;
  //   }
  // }

  Future<StorageFormat?> getNextUp(String seriesId) async {
    final res = await http.get(Uri.parse('$uri/$seriesId'));
    if (res.ok) {
      final Map<String, dynamic> decoded = jsonDecode(res.body);
      return StorageFormat.fromJson(decoded["payload"]);
    } else if (res.statusCode == 404) {
      return null;
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<void> createNextUp({
    required final String seriesId,
    required final int seasonIndex,
    required final int episodeIndex,
  }) async {
    final res = await http.post(
      Uri.parse('$uri/create'),
      body: jsonEncode({
        "id": seriesId,
        "seasonIndex": seasonIndex.toString(),
        "episodeIndex": episodeIndex.toString(),
      }),
    );
    if (!res.ok) {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<void> addOrUpdateNextUp({
    required final String seriesId,
    required final int seasonIndex,
    required final int episodeIndex,
  }) async {
    final res = await http.put(
      Uri.parse('$uri/$seriesId'),
      body: {
        "seasonIndex": seasonIndex.toString(),
        "episodeIndex": episodeIndex.toString()
      },
    );
    if (!res.ok) {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  // Future<bool?> checkFavorite(MediaType mediaType, String id) async {
  //   try {
  //     if (await storage.ready) {
  //       await _initStorage();
  //       if (mediaType == MediaType.Movie) {
  //         final List<dynamic> data =
  //             storage.getItem("fav_movies").cast<String>();
  //         if (data.contains(id))
  //           return true;
  //         else
  //           return false;
  //       } else {
  //         final List<String> data =
  //             storage.getItem("fav_series").cast<String>();
  //         if (data.contains(id))
  //           return true;
  //         else
  //           return false;
  //       }
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> removeNextUp(String seriesId) async {
    final res = await http.delete(
      Uri.parse('$uri/$seriesId'),
    );
    if (!res.ok) {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }
}
