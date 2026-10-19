import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/university_provider.dart';
import '../widgets/university_card.dart';
import 'university_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _cityController = TextEditingController();
  final _programController = TextEditingController();
  final _minFeeController = TextEditingController();
  final _maxFeeController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _programController.dispose();
    _minFeeController.dispose();
    _maxFeeController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final city = _cityController.text.trim();
    final programName = _programController.text.trim();
    final minFee = double.tryParse(_minFeeController.text.trim());
    final maxFee = double.tryParse(_maxFeeController.text.trim());

    ref.read(universityListProvider.notifier).searchUniversities(
          city: city.isEmpty ? null : city,
          programName: programName.isEmpty ? null : programName,
          minFee: minFee,
          maxFee: maxFee,
        );
  }

  void _clearFilters() {
    _cityController.clear();
    _programController.clear();
    _minFeeController.clear();
    _maxFeeController.clear();
    ref.read(universityListProvider.notifier).fetchUniversities();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(universityListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _buildResults(state),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                hintText: 'e.g., Lahore, Islamabad',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _programController,
              decoration: const InputDecoration(
                labelText: 'Program Name',
                hintText: 'e.g., Computer Science',
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minFeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Fee (PKR)',
                      prefixIcon: Icon(Icons.money),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxFeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Fee (PKR)',
                      prefixIcon: Icon(Icons.money),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    child: const Text('Search'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(UniversityListState state) {
    switch (state.loadingState) {
      case LoadingState.initial:
        return const Center(child: Text('Enter filters and search'));
      case LoadingState.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingState.loaded:
        if (state.universities.isEmpty) {
          return const Center(
            child: Text('No universities match your criteria'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
        );
      case LoadingState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.errorMessage ?? 'An error occurred'),
            ],
          ),
        );
    }
  }
}
