import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pricing_provider.dart';
import '../data/request_type_model.dart';

class PricingPage extends ConsumerWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricingAsync = ref.watch(pricingProvider);

    return Scaffold(
      body: pricingAsync.when(
        data: (requestTypes) {
          if (requestTypes.isEmpty) {
            return const Center(child: Text('No request types found.'));
          }
          return ListView.builder(
            itemCount: requestTypes.length,
            itemBuilder: (context, index) {
              final reqType = requestTypes[index];
              return Opacity(
                opacity: reqType.isActive ? 1.0 : 0.6,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(reqType.name, style: TextStyle(
                          decoration: reqType.isActive ? null : TextDecoration.lineThrough,
                        )),
                        const SizedBox(width: 8),
                        if (!reqType.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Inactive', style: TextStyle(color: Colors.red, fontSize: 10)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 10)),
                          ),
                      ],
                    ),
                    subtitle: Text('Slug: ${reqType.slug}\nPrice: \$${reqType.price.toStringAsFixed(2)}'),
                    isThreeLine: true,
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
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, RequestTypeModel reqType) {
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
              title: Text('Edit Service: ${reqType.slug}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '\$ ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Active Status'),
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
                  child: const Text('Cancel'),
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
