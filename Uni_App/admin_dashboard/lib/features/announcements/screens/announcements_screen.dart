import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/announcements_provider.dart';
import '../widgets/announcement_form_dialog.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsState = ref.watch(announcementsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.announcementsManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(announcementsProvider.notifier).fetchAnnouncements();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AnnouncementFormDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newAnnouncement),
      ),
      body: announcementsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: $error')),
        data: (announcements) {
          if (announcements.isEmpty) {
            return Center(child: Text(l10n.noAnnouncementsCurrently));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                columns: [
                  DataColumn(label: Text(l10n.imageLabel)),
                  DataColumn(label: Text(l10n.titleLabel)),
                  DataColumn(label: Text(l10n.targetAudience)),
                  DataColumn(label: Text(l10n.publishDate)),
                  DataColumn(label: Text(l10n.statusColumn)),
                  DataColumn(label: Text(l10n.actionsColumn)),
                ],
                rows: announcements.map((announcement) {
                  return DataRow(
                    cells: [
                      DataCell(
                        announcement.imageUrl != null
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      child: Stack(
                                        children: [
                                          Image.network(announcement.imageUrl!),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(announcement.imageUrl!, width: 50, height: 50, fit: BoxFit.cover),
                              )
                            : const Text('-'),
                      ),
                      DataCell(Text(announcement.title)),
                      DataCell(Text(announcement.targetAudienceLabel)),
                      DataCell(Text(announcement.publishedAt?.toString().substring(0, 10) ?? '-')),
                      DataCell(
                        Switch(
                          value: announcement.isActive,
                          onChanged: (val) {
                            ref.read(announcementsProvider.notifier).toggleActive(announcement.id);
                          },
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AnnouncementFormDialog(announcement: announcement),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(l10n.confirmDelete),
                                    content: Text(l10n.confirmDeleteAnnouncement),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  ref.read(announcementsProvider.notifier).deleteAnnouncement(announcement.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
