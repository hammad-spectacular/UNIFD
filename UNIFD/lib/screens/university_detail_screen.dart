import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/university.dart';
import '../models/program.dart';
import '../providers/university_provider.dart';
import '../providers/favorites_provider.dart';

class UniversityDetailScreen extends ConsumerWidget {
  final String universityId;

  const UniversityDetailScreen({super.key, required this.universityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universityAsync = ref.watch(universityProvider(universityId));
    final programsAsync = ref.watch(programsProvider(universityId));
    final favoritesState = ref.watch(favoritesProvider);
    final isFavorite = favoritesState.favoriteIds.contains(universityId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('University Details'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(universityId);
            },
          ),
        ],
      ),
      body: universityAsync.when(
        data: (university) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, university),
              _buildProgramsSection(context, programsAsync),
              _buildDisclaimer(context),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, University university) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (university.logoUrl != null)
              Center(
                child: Image.network(
                  university.logoUrl!,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.school, size: 100);
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              university.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_city, size: 20),
                const SizedBox(width: 8),
                Text(university.city),
                const SizedBox(width: 16),
                Chip(
                  label: Text(university.type),
                  backgroundColor: university.type == 'public'
                      ? Colors.blue.shade100
                      : Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final uri = Uri.parse(university.website);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.language, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Visit Website',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last verified: ${_formatDate(university.lastVerified)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(university.sourceLink);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.verified),
              label: const Text('Verify on Official Site'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _showReportDialog(context, university);
              },
              icon: const Icon(Icons.report),
              label: const Text('Report Wrong Info'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsSection(BuildContext context, AsyncValue<List<Program>> programsAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Programs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          programsAsync.when(
            data: (programs) {
              if (programs.isEmpty) {
                return const Text('No programs available');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: programs.length,
                itemBuilder: (context, index) {
                  final program = programs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.school, size: 16),
                              const SizedBox(width: 4),
                              Text(program.degreeLevel),
                              const SizedBox(width: 16),
                              const Icon(Icons.schedule, size: 16),
                              const SizedBox(width: 4),
                              Text(program.duration),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tuition: PKR ${program.tuitionFee.toStringAsFixed(0)} / ${program.feePeriod}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (program.registrationFee != null) ...[
                            const SizedBox(height: 4),
                            Text('Registration Fee: PKR ${program.registrationFee!.toStringAsFixed(0)}'),
                          ],
                          if (program.deadline != null) ...[
                            const SizedBox(height: 4),
                            Text('Deadline: ${_formatDate(program.deadline!)}'),
                          ],
                          if (program.eligibility != null && program.eligibility!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Eligibility: ${program.eligibility}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error loading programs: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.amber.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Information is collected from official sources. Always confirm with the university.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, University university) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Wrong Info'),
        content: Text('Report incorrect information for ${university.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted. Thank you!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
