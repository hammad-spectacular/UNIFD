import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/favorites_service.dart';

// Favorites state
class FavoritesState {
  final Set<String> favoriteIds;
  final bool isLoading;

  FavoritesState({
    this.favoriteIds = const {},
    this.isLoading = false,
  });

  FavoritesState copyWith({
    Set<String>? favoriteIds,
    bool? isLoading,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Favorites notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(FavoritesState()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    state = state.copyWith(isLoading: true);
    try {
      final favorites = await FavoritesService.getFavorites();
      state = state.copyWith(favoriteIds: favorites, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleFavorite(String universityId) async {
    final isFav = state.favoriteIds.contains(universityId);
    if (isFav) {
      await FavoritesService.removeFavorite(universityId);
      final newFavorites = Set<String>.from(state.favoriteIds)..remove(universityId);
      state = state.copyWith(favoriteIds: newFavorites);
    } else {
      await FavoritesService.addFavorite(universityId);
      final newFavorites = Set<String>.from(state.favoriteIds)..add(universityId);
      state = state.copyWith(favoriteIds: newFavorites);
    }
  }

  Future<void> clearAll() async {
    await FavoritesService.clearFavorites();
    state = state.copyWith(favoriteIds: {});
  }
}

// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});
