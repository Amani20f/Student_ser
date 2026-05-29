import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool readOnly;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const LabeledTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.readOnly = false,
    this.maxLines = 1,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          validator: validator,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

class DatePickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const DatePickerField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: label,
      controller: controller,
      readOnly: true,
      hint: 'اختر التاريخ',
      validator: validator,
      suffixIcon: IconButton(
        icon: Icon(
          Icons.calendar_today,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () => _selectDate(context),
      ),
    );
  }
}

class DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? hint;

  const DropdownField({
    super.key,
    required this.label,
    required this.items,
    this.onChanged,
    this.value,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: value,
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(hintText: hint ?? 'اختر من القائمة'),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

class FileUploadWidget extends StatelessWidget {
  final String label;
  final List<PlatformFile> files;
  final VoidCallback onPickFiles;
  final Function(PlatformFile) onRemoveFile;
  final bool allowMultiple;
  final String? errorText;

  const FileUploadWidget({
    super.key,
    required this.label,
    required this.files,
    required this.onPickFiles,
    required this.onRemoveFile,
    this.allowMultiple = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            if (files.isNotEmpty && !allowMultiple)
              TextButton(
                onPressed: onPickFiles,
                child: Text(
                  'تغيير الملف',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (files.isEmpty)
          InkWell(
            onTap: onPickFiles,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: errorText != null ? Colors.red : theme.dividerColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 32,
                    color: errorText != null
                        ? Colors.red
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط لرفع الملفات',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: errorText != null
                          ? Colors.red
                          : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  Text('(PDF, Image)', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          )
        else
          Column(
            children: files.map((file) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        file.name,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () => onRemoveFile(file),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        if (files.isNotEmpty && allowMultiple)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onPickFiles,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('إضافة ملف آخر'),
            ),
          ),

        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 12),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
