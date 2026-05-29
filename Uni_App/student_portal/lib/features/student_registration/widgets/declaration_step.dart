import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/features/student_registration/cubit/registration_cubit.dart';

import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/student_registration/widgets/step_container.dart';

class DeclarationStep extends StatefulWidget {
  const DeclarationStep({super.key});

  @override
  State<DeclarationStep> createState() => _DeclarationStepState();
}

class _DeclarationStepState extends State<DeclarationStep> {
  // Simple signature simulation
  final List<Offset?> _points = [];
  final GlobalKey _signatureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<RegistrationCubit>();

    return BlocBuilder<RegistrationCubit, RegistrationState>(
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        return StepContainer(
          title: l10n.declaration, // Ensure key exists or use fallback
          icon: Icons.assignment_turned_in_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Simulate uploading receipt
                    if (state.data.receiptPath == null) {
                      cubit.updateData(
                        state.data.copyWith(
                          receiptPath: 'uploaded_receipt.pdf',
                        ),
                      );
                    } else {
                      // Remove receipt if clicked again
                      cubit.updateData(
                        state.data.copyWith(receiptPath: null),
                      );
                    }
                  },
                  icon: Icon(
                    state.data.receiptPath != null
                        ? Icons.check_circle_rounded
                        : Icons.receipt_long_rounded,
                  ),
                  label: Text(l10n.uploadReceipt),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        state.data.receiptPath != null
                            ? Colors.green
                            : const Color(0xFF009688),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.declarationText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: state.data.declarationChecked,
                onChanged: (value) => cubit.updateData(
                  state.data.copyWith(declarationChecked: value),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.orange,
                checkColor: Colors.white,
                side: const BorderSide(color: Colors.orange, width: 2.0),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.signature,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                key: _signatureKey,
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final RenderBox? renderBox =
                        _signatureKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    if (renderBox != null) {
                      setState(() {
                        _points.add(
                          renderBox.globalToLocal(details.globalPosition),
                        );
                      });
                      // Mark as signed if not already
                      if (state.data.signaturePath == null) {
                        cubit.updateData(
                          state.data.copyWith(signaturePath: 'signed'),
                        );
                      }
                    }
                  },
                  onPanEnd: (details) {
                    _points.add(null);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: SignaturePainter(
                        points: _points,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _points.clear();
                    });
                    cubit.updateData(state.data.copyWith(signaturePath: null));
                  },
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  label: Text(l10n.clearSignature),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;

  SignaturePainter({required this.points, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Adjust points to local coordinates of the container if needed,
        // but RenderBox logic in GestureDetector usually handles it.
        // However, the RenderBox used was the whole widget.
        // To be precise, we should use a key or LayoutBuilder.
        // For this simple demo, we will blindly draw.
        // Note: The offsets are relative to the top-left of the declared RenderBox.
        // If the RenderBox is the stateful widget, it includes the checkbox.
        // This might cause offset issues.
        // Fix: Use a Builder or key for the Container to get its specific RenderBox.
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
