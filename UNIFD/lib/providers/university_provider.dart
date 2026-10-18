import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/university.dart';
import '../models/program.dart';
import '../services/supabase_service.dart';

// Loading state enum
enum LoadingState {
  initial,
  loading,
  loaded,
  error,
}

// University list state
class UniversityListState {
  final List<University> universities;
  final LoadingState loadingState;
  final String? errorMessage;

  UniversityListState({
    this.universities = const [],
    this.loadingState = LoadingState.initial,
    this.errorMessage,
  });

  UniversityListState copyWith({
    List<University>? universities,
    LoadingState? loadingState,
    String? errorMessage,
  }) {
    return UniversityListState(
      universities: universities ?? this.universities,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// University list notifier
class UniversityListNotifier extends StateNotifier<UniversityListState> {
  UniversityListNotifier() : super(UniversityListState());

  Future<void> fetchUniversities() async {
    state = state.copyWith(loadingState: LoadingState.loading, errorMessage: null);
    try {
      final universities = await SupabaseService.getUniversities();
      state = state.copyWith(
        universities: universities,
        loadingState: LoadingState.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> searchUniversities({
    String? city,
    String? programName,
    double? minFee,
    double? maxFee,
  }) async {
    state = state.copyWith(loadingState: LoadingState.loading, errorMessage: null);
    try {
      final universities = await SupabaseService.searchUniversities(
        city: city,
        programName: programName,
        minFee: minFee,
        maxFee: maxFee,
      );
      state = state.copyWith(
        universities: universities,
        loadingState: LoadingState.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        loadingState: LoadingState.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// University list provider
final universityListProvider =
    StateNotifierProvider<UniversityListNotifier, UniversityListState>((ref) {
  return UniversityListNotifier();
});

// Single university provider
final universityProvider = FutureProvider.family<University, String>((ref, id) async {
  return SupabaseService.getUniversityById(id);
});

// Programs provider for a university
final programsProvider = FutureProvider.family<List<Program>, String>((ref, universityId) async {
  return SupabaseService.getProgramsByUniversity(universityId);
});
