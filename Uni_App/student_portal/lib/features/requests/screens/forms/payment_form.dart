import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/features/auth/cubit/auth_cubit.dart';
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
  final String? initialRefNumber;
  final String? initialServiceType;

  const PaymentFormScreen({
    super.key,
    this.initialRefNumber,
    this.initialServiceType,
  });

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

    if (widget.initialRefNumber != null) {
      _refNumberController.text = widget.initialRefNumber!;
    }
    if (widget.initialServiceType != null) {
      _paymentTypeController.text = widget.initialServiceType!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _onPaymentTypeChanged(widget.initialServiceType);
        } catch (e) {
          // ignore if option not exactly found
        }
      });
    }
  }

  void _fetchPaymentOptions() {
    setState(() {
      _paymentOptions = [
        PaymentItem(
          displayName: 'تظلم — 10 دولار',
          amount: '10',
          requestId: '1',
          serviceType: 'appeal',
        ),
        PaymentItem(
          displayName: 'إيقاف قيد — 10 دولار',
          amount: '10',
          requestId: '2',
          serviceType: 'stop_enrollment',
        ),
        PaymentItem(
          displayName: 'إعادة قيد — 10 دولار',
          amount: '10',
          requestId: '3',
          serviceType: 're_enrollment',
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
        paymentCategory: _selectedPaymentItem?.serviceType,
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
        final errorMsg = e.toString().replaceAll('ApiException:', '').replaceAll('Exception:', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
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
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    String name = '';
                    String studentNumber = '';
                    if (state is Authenticated) {
                      final user = state.user;
                      name = user['name'] ?? '';
                      studentNumber = user['student']?['student_number'] ?? '';
                    }
                    return Column(
                      children: [
                        LabeledTextField(
                          label: 'الاسم الكامل',
                          readOnly: true,
                          hint: name.isNotEmpty ? name : 'جاري التحميل...',
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'الرقم الجامعي',
                          readOnly: true,
                          hint: studentNumber.isNotEmpty ? studentNumber : 'جاري التحميل...',
                        ),
                      ],
                    );
                  },
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
                  value: _paymentTypeController.text.isNotEmpty ? _paymentTypeController.text : null,
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
                  validator: (val) {
                    final isRequired = _selectedPaymentItem != null &&
                        (_selectedPaymentItem!.serviceType == 'appeal' ||
                         _selectedPaymentItem!.serviceType == 'stop_enrollment' ||
                         _selectedPaymentItem!.serviceType == 're_enrollment');
                    if (isRequired && (val == null || val.trim().isEmpty)) {
                      return 'مطلوب';
                    }
                    return null;
                  },
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
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
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
