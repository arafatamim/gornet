import 'package:localstorage/localstorage.dart';

class StorageFormat {
  final String seriesId;
  final String seasonId;
  final String episodeId;

  StorageFormat({
    required final this.seriesId,
    required final this.seasonId,
    required final this.episodeId,
  });

  StorageFormat.fromJson(Map<String, dynamic> json)
      : seriesId = json["seriesId"],
        seasonId = json["seasonId"],
        episodeId = json["episodeId"];

  Map<String, dynamic> toJson() => {
        "seriesId": seriesId,
        "seasonId": seasonId,
        "episodeId": episodeId,
      };

  static List<StorageFormat> fromJsonArray(List<dynamic> json) =>
      json.map((e) => StorageFormat.fromJson(e)).toSet().toList();

  static List<Map<String, dynamic>> toJsonArray(List<StorageFormat> items) =>
      items.map((e) => e.toJson()).toSet().toList();
}

class NextUpService {
  final LocalStorage storage;
  final key;

  NextUpService([this.key = "next_up"]) : storage = LocalStorage(key);

  Future<void> _initStorage() async {
    if (storage.getItem(key) == null) {
      await storage.setItem(key, []);
    }
  }

  List<dynamic> get _getItem => storage.getItem(key);

  Future<void> _saveKey(List<Map<String, dynamic>> item) =>
      storage.setItem("next_up", item);

  int? _getItemIndex(String seriesId, List<StorageFormat> items) {
    try {
      final index = items.indexWhere((element) => element.seriesId == seriesId);
      if (index < 0) {
        return null;
      } else
        return index;
    } on StateError {
      return null;
    }
  }

  List<StorageFormat> _updateOrAdd(
      StorageFormat item, List<StorageFormat> items) {
    final existingIndex = _getItemIndex(item.seriesId, items);
    if (existingIndex == null) {
      items.add(item);
      return items;
    } else {
      items[existingIndex] = item;
      return items;
    }
  }

  Future<StorageFormat?> getNextUp(String seriesId) async {
    if (await storage.ready) {
      await _initStorage();
      final List<StorageFormat> items = StorageFormat.fromJsonArray(_getItem);
      final itemIndex = _getItemIndex(seriesId, items);
      if (itemIndex != null) {
        return items[itemIndex];
      } else
        return null;
    }
  }

  Future<void> updateNextUp({
    required final seriesId,
    required final seasonId,
    required final episodeId,
  }) async {
    try {
      if (await storage.ready) {
        await _initStorage();
        final List<StorageFormat> data = StorageFormat.fromJsonArray(_getItem);
        final newData = _updateOrAdd(
          StorageFormat(
            seriesId: seriesId,
            seasonId: seasonId,
            episodeId: episodeId,
          ),
          data,
        );
        return await _saveKey(StorageFormat.toJsonArray(newData));
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

  Future<void> removeNextUp(String seriesId) async {
    try {
      if (await storage.ready) {
        await _initStorage();
        final List<StorageFormat> data = StorageFormat.fromJsonArray(_getItem);
        data.removeWhere((item) => item.seriesId == seriesId);
        return await _saveKey(StorageFormat.toJsonArray(data));
      }
    } catch (e) {
      print(e);
    }
  }
}
