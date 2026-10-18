import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/university_provider.dart';
import '../widgets/university_card.dart';
import 'university_detail_screen.dart';

class UniversityListScreen extends ConsumerStatefulWidget {
  const UniversityListScreen({super.key});

  @override
  ConsumerState<UniversityListScreen> createState() => _UniversityListScreenState();
}

class _UniversityListScreenState extends ConsumerState<UniversityListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(universityListProvider.notifier).fetchUniversities());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(universityListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Universities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.compare),
            onPressed: () {
              Navigator.pushNamed(context, '/compare');
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(UniversityListState state) {
    switch (state.loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingState.loaded:
        if (state.universities.isEmpty) {
          return const Center(
            child: Text('No universities found'),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(universityListProvider.notifier).fetchUniversities(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.universities.length,
            itemBuilder: (context, index) {
              final university = state.universities[index];
              return UniversityCard(
                university: university,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UniversityDetailScreen(universityId: university.id),
                    ),
                  );
                },
              );
            },
          ),
        );
      case LoadingState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(universityListProvider.notifier).fetchUniversities(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    }
  }
}
