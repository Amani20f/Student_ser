import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../models/announcement.dart';
import '../providers/announcements_provider.dart';
import '../../programs/providers/programs_provider.dart';
import '../../courses/providers/colleges_provider.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';

class AnnouncementFormDialog extends ConsumerStatefulWidget {
  final Announcement? announcement;

  const AnnouncementFormDialog({super.key, this.announcement});

  @override
  ConsumerState<AnnouncementFormDialog> createState() => _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState extends ConsumerState<AnnouncementFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _targetAudience = 'all_students';
  int? _targetProgramId;
  int? _targetCollegeId;
  bool _isActive = true;
  bool _sendNotification = false;
  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title ?? '');
    _contentController = TextEditingController(text: widget.announcement?.content ?? '');
    if (widget.announcement != null) {
      _targetAudience = widget.announcement!.targetAudience;
      _targetProgramId = widget.announcement!.targetProgramId;
      _targetCollegeId = widget.announcement!.targetCollegeId;
      _isActive = widget.announcement!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final programsState = ref.watch(publicProgramsProvider);
    final programs = programsState.value ?? [];

    final collegesState = ref.watch(collegesProvider);
    final colleges = collegesState.value ?? [];

    return AlertDialog(
      title: Text(widget.announcement == null ? l10n.newAnnouncement : l10n.edit),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: l10n.titleLabel, border: const OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'المحتوى', border: OutlineInputBorder()),
                  maxLines: 5,
                  validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _targetAudience,
                  decoration: const InputDecoration(labelText: 'الفئة المستهدفة', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'all_students', child: Text('جميع الطلاب')),
                    DropdownMenuItem(value: 'specific_college', child: Text('كلية محددة')),
                    DropdownMenuItem(value: 'specific_program', child: Text('تخصص محدد')),
                    DropdownMenuItem(value: 'staff', child: Text('الموظفين/أعضاء هيئة التدريس')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _targetAudience = val!;
                      _targetProgramId = null;
                      _targetCollegeId = null;
                    });
                  },
                ),
                if (_targetAudience == 'specific_program') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _targetProgramId,
                    decoration: const InputDecoration(labelText: 'البرنامج المستهدف', border: OutlineInputBorder()),
                    items: programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                    onChanged: (val) => setState(() => _targetProgramId = val),
                    validator: (value) => value == null ? 'مطلوب' : null,
                  ),
                ],
                if (_targetAudience == 'specific_college') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _targetCollegeId,
                    decoration: const InputDecoration(labelText: 'الكلية المستهدفة', border: OutlineInputBorder()),
                    items: colleges.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _targetCollegeId = val),
                    validator: (value) => value == null ? 'مطلوب' : null,
                  ),
                ],
                const SizedBox(height: 16),
                if (widget.announcement?.imageUrl != null && _imageBytes == null) ...[
                  Image.network(widget.announcement!.imageUrl!, height: 100, fit: BoxFit.cover),
                  const SizedBox(height: 8),
                ] else if (_imageBytes != null) ...[
                  Image.memory(_imageBytes!, height: 100, fit: BoxFit.cover),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: Text(_imageBytes != null ? 'تغيير الصورة' : 'إرفاق صورة (اختياري)'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('مفعل'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
                SwitchListTile(
                  title: const Text('إرسال إشعار للمستهدفين فوراً'),
                  subtitle: const Text('سيتم تنبيه الفئة المستهدفة في نظام الإشعارات'),
                  value: _sendNotification,
                  onChanged: (val) => setState(() => _sendNotification = val),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _imageName = result.files.first.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text,
      'content': _contentController.text,
      'target_audience': _targetAudience,
      if (_targetProgramId != null) 'target_program_id': _targetProgramId,
      if (_targetCollegeId != null) 'target_college_id': _targetCollegeId,
      'is_active': _isActive,
      'send_notification': _sendNotification,
    };

    http.MultipartFile? imageFile;
    if (_imageBytes != null && _imageName != null) {
      imageFile = http.MultipartFile.fromBytes('image', _imageBytes!, filename: _imageName);
    }

    final notifier = ref.read(announcementsProvider.notifier);
    bool success;
    if (widget.announcement == null) {
      success = await notifier.createAnnouncement(data, imageFile: imageFile);
    } else {
      success = await notifier.updateAnnouncement(widget.announcement!.id, data, imageFile: imageFile);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل الحفظ')),
        );
      }
    }
  }
}
