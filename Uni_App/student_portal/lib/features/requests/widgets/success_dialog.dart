import 'package:university_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showSuccessDialog(BuildContext context, String referenceNumber, VoidCallback onOk) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          const Text('تم إرسال الطلب بنجاح'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الرقم المرجعي:'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#$referenceNumber',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                  textDirection: TextDirection.ltr,
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'نسخ الرقم المرجعي',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: referenceNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الرقم المرجعي')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.useThisNumberForPayment),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context); // close dialog
            onOk(); // execute callback (e.g., Navigator.pop(context) to leave form)
          },
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ],
    ),
  );
}
