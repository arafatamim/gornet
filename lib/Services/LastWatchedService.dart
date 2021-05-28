import 'package:chillyflix/Services/StorageService.dart';
import 'package:localstorage/localstorage.dart';

class StorageFormat {
  final String id;
  final bool isMovie;

  StorageFormat({required this.id, required this.isMovie});

  StorageFormat.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        isMovie = json["isMovie"];

  Map<String, dynamic> toJson() => {"id": id, "isMovie": isMovie};

  static List<StorageFormat> fromJsonArray(List<Map<String, dynamic>> json) =>
      json.map((e) => StorageFormat.fromJson(e)).toSet().toList();
}

class LastWatchedService {
  final LocalStorage storage;

  LastWatchedService([key = "last_watched"]) : storage = LocalStorage(key);

  Future<void> _initStorage() async {
    if (storage.getItem("last_watched") == null) {
      await storage.setItem("last_watched", []);
    }
  }

  List<Map<String, dynamic>> get _getKey => storage.getItem("last_watched");

  Future<void> _saveKey(List<StorageFormat> item) =>
      storage.setItem("last_watched", item);

  Future<List<StorageFormat>?> getLastWatched() async {
    if (await storage.ready) {
      await _initStorage();
      final List<StorageFormat> items = StorageFormat.fromJsonArray(_getKey);
      return items;
    }
  }

  Future<void> saveLastWatched(MediaType mediaType, String id) async {
    try {
      if (await storage.ready) {
        await _initStorage();
        final List<StorageFormat> data = StorageFormat.fromJsonArray(_getKey);
        data.add(StorageFormat(id: id, isMovie: mediaType == MediaType.Movie));
        return await _saveKey(data);
      }
    } catch (e) {
      print(e);
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

  /// Returns a boolean indicating if item was in list
  Future<void> removeLastWatched(MediaType mediaType, String id) async {
    try {
      if (await storage.ready) {
        await _initStorage();
        final List<StorageFormat> data = StorageFormat.fromJsonArray(_getKey);
        return data.removeWhere((item) => item.id == id);
      }
    } catch (e) {
      print(e);
    }
  }
}
