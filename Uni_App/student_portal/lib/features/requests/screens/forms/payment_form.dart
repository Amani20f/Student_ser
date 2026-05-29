import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'package:university_app/features/requests/data/requests_repository.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';

class PaymentItem {
  final String displayName;
  final String amount;
  final String? requestId;
  final String? serviceType;
  final bool isEditable;

  PaymentItem({
    required this.displayName,
    required this.amount,
    this.requestId,
    this.serviceType,
    this.isEditable = false,
  });
}

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _paymentTypeController = TextEditingController();
  final _amountController = TextEditingController();
  final _refNumberController = TextEditingController();

  List<PlatformFile> _uploadedFiles = [];
  bool _isSubmitting = false;
  bool _isAmountEditable = false;

  List<PaymentItem> _paymentOptions = [];
  PaymentItem? _selectedPaymentItem;

  @override
  void initState() {
    super.initState();
    _fetchPaymentOptions();
  }

  void _fetchPaymentOptions() {
    setState(() {
      _paymentOptions = [
        PaymentItem(
          displayName: 'تظلم — 10 دولار',
          amount: '10',
          requestId: '1',
        ),
        PaymentItem(
          displayName: 'إيقاف قيد — 10 دولار',
          amount: '10',
          requestId: '2',
        ),
        PaymentItem(
          displayName: 'إعادة قيد — 10 دولار',
          amount: '10',
          requestId: '3',
        ),
        PaymentItem(
          displayName: 'رسوم البطاقة الجامعية — 5 دولار',
          amount: '5',
          serviceType: 'student_card',
        ),
        PaymentItem(
          displayName: 'الرسوم الدراسية',
          amount: '',
          serviceType: 'tuition_fee',
          isEditable: true,
        ),
      ];
    });
  }

  @override
  void dispose() {
    _paymentTypeController.dispose();
    _amountController.dispose();
    _refNumberController.dispose();
    super.dispose();
  }

  void _onPaymentTypeChanged(String? value) {
    if (value == null) return;
    _paymentTypeController.text = value;
    final selectedItem = _paymentOptions.firstWhere(
      (item) => item.displayName == value,
    );
    setState(() {
      _selectedPaymentItem = selectedItem;
      _isAmountEditable = selectedItem.isEditable;
      if (!selectedItem.isEditable) {
        _amountController.text = selectedItem.amount;
      } else {
        _amountController.text = '';
      }
    });
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null) {
      setState(() {
        _uploadedFiles = [result.files.single];
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_uploadedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى رفع إيصال السداد'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<RequestsRepository>();

      final receiptFile = File(_uploadedFiles.first.path!);
      final amount = double.tryParse(_amountController.text.trim()) ?? 0;

      await repo.submitPayment(
        amount: amount,
        purpose: _paymentTypeController.text.trim(),
        refNumber: _refNumberController.text.trim(),
        receiptFile: receiptFile,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تم بنجاح'),
            content: const Text('تم إرسال إيصال السداد بنجاح وسوف يتم مراجعته.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الإرسال: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نموذج سداد الرسوم')),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بيانات الطالب',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                const LabeledTextField(
                  label: 'الاسم الكامل',
                  readOnly: true,
                  hint: 'نورة أحمد',
                ),
                const SizedBox(height: 16),
                const LabeledTextField(
                  label: 'الرقم الجامعي',
                  readOnly: true,
                  hint: '20241010',
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Text(
                  'تفاصيل السداد',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                DropdownField(
                  label: 'نوع الخدمة / الرسوم',
                  items: _paymentOptions.map((e) => e.displayName).toList(),
                  onChanged: _onPaymentTypeChanged,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'الرقم المرجعي للطلب (REF-XXXXXX)',
                  controller: _refNumberController,
                  hint: 'أدخل الرقم المرجعي الموجود في رسالة التأكيد',
                  validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'المبلغ (دولار)',
                  controller: _amountController,
                  readOnly: !_isAmountEditable,
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 24),
                FileUploadWidget(
                  label: 'إيصال السداد (مطلوب)',
                  files: _uploadedFiles,
                  onPickFiles: _pickFiles,
                  onRemoveFile: (file) =>
                      setState(() => _uploadedFiles.clear()),
                  errorText: null,
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'أقر بأن إيصال السداد المرفق صحيح وساري المفعول.',
                    style: GoogleFonts.almarai(fontSize: 13),
                  ),
                  value: true,
                  onChanged: (val) {},
                  activeColor: Theme.of(context).colorScheme.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'إرسال الإيصال',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
