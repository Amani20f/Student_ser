import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pricing_provider.dart';
import '../data/request_type_model.dart';

class PricingPage extends ConsumerWidget {
  const PricingPage({super.key});

  String _getLocalizedName(BuildContext context, String slug, String fallbackName) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (slug) {
      case 're_enrollment':
        return isAr ? 'إعادة قيد' : 'Re-enrollment';
      case 'grade_grievance':
        return isAr ? 'تظلم درجات' : 'Grade Grievance';
      case 'aathr-ghyab':
      case 'absence_excuse':
        return isAr ? 'عذر غياب' : 'Absence Excuse';
      case 'tagyl-dras':
      case 'suspension_of_enrollment':
        return isAr ? 'تأجيل دراسة' : 'Stop Enrollment';
      default:
        return fallbackName;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricingAsync = ref.watch(pricingProvider);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: pricingAsync.when(
        data: (requestTypes) {
          if (requestTypes.isEmpty) {
            return Center(
              child: Text(
                isAr ? 'لم يتم العثور على خدمات.' : 'No request types found.',
              ),
            );
          }
          return ListView.builder(
            itemCount: requestTypes.length,
            itemBuilder: (context, index) {
              final reqType = requestTypes[index];
              final serviceName = _getLocalizedName(context, reqType.slug, reqType.name);
              
              return Opacity(
                opacity: reqType.isActive ? 1.0 : 0.6,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    title: Text(
                      serviceName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: reqType.isActive ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          isAr
                              ? 'الحالة: ${reqType.isActive ? "نشط" : "غير نشط"}'
                              : 'Status: ${reqType.isActive ? "Active" : "Inactive"}',
                          style: TextStyle(
                            color: reqType.isActive ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                              ? 'رسوم الخدمة: ${reqType.price.toStringAsFixed(0)} دولار'
                              : 'Service Fee: \$${reqType.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, ref, reqType),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Text(
            isAr ? 'خطأ: $err' : 'Error: $err',
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, RequestTypeModel reqType) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final serviceName = _getLocalizedName(context, reqType.slug, reqType.name);

    final nameController = TextEditingController(text: reqType.name);
    final descController = TextEditingController(text: reqType.description ?? '');
    final priceController = TextEditingController(text: reqType.price.toStringAsFixed(2));
    bool isActive = reqType.isActive;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isAr ? 'تعديل الخدمة: $serviceName' : 'Edit Service: $serviceName'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: isAr ? 'الاسم' : 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(labelText: isAr ? 'الوصف' : 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: isAr ? 'السعر' : 'Price',
                        prefixText: isAr ? 'دولار ' : '\$ ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(isAr ? 'الحالة نشطة' : 'Active Status'),
                      value: isActive,
                      onChanged: (val) {
                        setState(() {
                          isActive = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newPrice = double.tryParse(priceController.text) ?? 0.0;
                    ref.read(pricingNotifierProvider.notifier).updateService(
                          reqType.id,
                          name: nameController.text,
                          description: descController.text,
                          price: newPrice,
                          isActive: isActive,
                        );
                    Navigator.pop(context);
                  },
                  child: Text(isAr ? 'حفظ' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
