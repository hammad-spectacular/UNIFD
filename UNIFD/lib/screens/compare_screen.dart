import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/university.dart';
import '../providers/university_provider.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final List<String> _selectedIds = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(universityListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Universities'),
        actions: [
          if (_selectedIds.length >= 2 && _selectedIds.length <= 3)
            TextButton(
              onPressed: _showComparison,
              child: const Text('Compare'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSelectionInfo(),
          Expanded(
            child: _buildUniversityList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Select 2-3 universities to compare (${_selectedIds.length}/3 selected)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (_selectedIds.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _selectedIds.clear());
                },
                child: const Text('Clear'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversityList(UniversityListState state) {
    switch (state.loadingState) {
      case LoadingState.initial:
        return const Center(child: CircularProgressIndicator());
      case LoadingState.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingState.loaded:
        if (state.universities.isEmpty) {
          return const Center(child: Text('No universities available'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.universities.length,
          itemBuilder: (context, index) {
            final university = state.universities[index];
            final isSelected = _selectedIds.contains(university.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(university.name),
                subtitle: Text('${university.city} • ${university.type}'),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        if (_selectedIds.length < 3) {
                          _selectedIds.add(university.id);
                        }
                      } else {
                        _selectedIds.remove(university.id);
                      }
                    });
                  },
                ),
              ),
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

  void _showComparison() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComparisonResultScreen(universityIds: _selectedIds),
      ),
    );
  }
}

class ComparisonResultScreen extends ConsumerWidget {
  final List<String> universityIds;

  const ComparisonResultScreen({super.key, required this.universityIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison'),
      ),
      body: FutureBuilder(
        future: Future.wait(
          universityIds.map((id) => ref.read(universityProvider(id).future)),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final universities = snapshot.data as List<University>;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('Feature')),
                  ...universities.map(
                    (u) => DataColumn(
                      label: SizedBox(
                        width: 200,
                        child: Text(
                          u.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
                rows: [
                  _buildRow('City', universities.map((u) => u.city).toList()),
                  _buildRow('Type', universities.map((u) => u.type).toList()),
                  _buildRow('Website', universities.map((u) => u.website).toList()),
                  _buildRow(
                    'Last Verified',
                    universities.map((u) => _formatDate(u.lastVerified)).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildRow(String label, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(label)),
        ...values.map((v) => DataCell(Text(v))),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
