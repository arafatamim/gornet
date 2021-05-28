import 'package:localstorage/localstorage.dart';

enum MediaType {
  Movie,
  Series,
}

class FavoritesService {
  final LocalStorage storage;

  FavoritesService([key = "default"]) : storage = LocalStorage(key);

  Future<void> _initStorage() async {
    if (storage.getItem("fav_movies") == null) {
      await storage.setItem("fav_movies", []);
      await storage.setItem("fav_series", []);
    }
  }

  Future<List<String>?> getFavorites(MediaType mediaType) async {
    if (await storage.ready) {
      await _initStorage();
      switch (mediaType) {
        case MediaType.Movie:
          final List<String> items =
              storage.getItem("fav_movies").cast<String>();
          return items;
        case MediaType.Series:
          final List<String> items =
              storage.getItem("fav_series").cast<String>();
          return items;
      }
    }
  }

  Future<List<String>?> getAllFavorites() async {
    try {
      if (await storage.ready) {
        await _initStorage();
        final List<String> movies =
            storage.getItem("fav_movies").cast<String>();
        final List<String> series =
            storage.getItem("fav_series").cast<String>();
        return movies + series;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveFavorite(MediaType mediaType, String id) async {
    try {
      if (await storage.ready) {
        await _initStorage();
        switch (mediaType) {
          case MediaType.Movie:
            final List<String> data =
                storage.getItem("fav_movies").cast<String>().toSet().toList();
            data.add(id);
            return await storage.setItem("fav_movies", data);
          case MediaType.Series:
            final List<String> data =
                storage.getItem("fav_series").cast<String>().toSet().toList();
            data.add(id);
            return await storage.setItem("fav_series", data);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool?> checkFavorite(MediaType mediaType, String id) async {
    try {
      if (await storage.ready) {
        await _initStorage();
        if (mediaType == MediaType.Movie) {
          final List<dynamic> data =
              storage.getItem("fav_movies").cast<String>();
          if (data.contains(id))
            return true;
          else
            return false;
        } else {
          final List<String> data =
              storage.getItem("fav_series").cast<String>();
          if (data.contains(id))
            return true;
          else
            return false;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  /// Returns a boolean indicating if item was in list
  Future<bool?> removeFavorite(MediaType mediaType, String id) async {
    try {
      if (await storage.ready) {
        await _initStorage();
        switch (mediaType) {
          case MediaType.Movie:
            final List<String> data =
                storage.getItem("fav_movies").cast<String>();
            return data.remove(id);
          case MediaType.Series:
            final List<String> data =
                storage.getItem("fav_series").cast<String>();
            return data.remove(id);
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
