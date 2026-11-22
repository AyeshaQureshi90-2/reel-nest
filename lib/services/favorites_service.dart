
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_model.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_movies';

  static final ValueNotifier<List<MovieModel>> favoritesNotifier =
      ValueNotifier<List<MovieModel>>([]);

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_favoritesKey);

    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);

      favoritesNotifier.value = decodedData
          .map(
            (item) => MovieModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    _isInitialized = true;
  }

  static Future<List<MovieModel>> getFavorites() async {
    await initialize();
    return favoritesNotifier.value;
  }

  static Future<void> addFavorite(MovieModel movie) async {
    await initialize();

    final favorites = List<MovieModel>.from(
      favoritesNotifier.value,
    );

    final alreadyExists = favorites.any(
      (item) =>
          item.id == movie.id &&
          item.mediaType == movie.mediaType,
    );

    if (!alreadyExists) {
      favorites.add(movie);
      await _saveFavorites(favorites);
    }
  }

  static Future<void> removeFavorite(
    int movieId, {
    String? mediaType,
  }) async {
    await initialize();

    final favorites = List<MovieModel>.from(
      favoritesNotifier.value,
    );

    favorites.removeWhere(
      (movie) =>
          movie.id == movieId &&
          (mediaType == null || movie.mediaType == mediaType),
    );

    await _saveFavorites(favorites);
  }

  static Future<bool> isFavorite(
    int movieId, {
    String? mediaType,
  }) async {
    await initialize();

    return favoritesNotifier.value.any(
      (movie) =>
          movie.id == movieId &&
          (mediaType == null || movie.mediaType == mediaType),
    );
  }

  static Future<void> _saveFavorites(
    List<MovieModel> favorites,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      favorites.map((movie) => movie.toJson()).toList(),
    );

    await prefs.setString(_favoritesKey, encodedData);

    favoritesNotifier.value = favorites;
  }
}
