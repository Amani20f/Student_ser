part of 'registration_cubit.dart';

enum RegistrationStatus {
  initial,
  valid,
  invalid,
  submitting,
  success,
  failure,
}

class RegistrationState extends Equatable {
  final int currentStep;
  final RegistrationData data;
  final RegistrationStatus status;
  final String? errorMessage;
  final String? applicationNumber;

  const RegistrationState({
    this.currentStep = 0,
    this.data = const RegistrationData(),
    this.status = RegistrationStatus.initial,
    this.errorMessage,
    this.applicationNumber,
  });

  RegistrationState copyWith({
    int? currentStep,
    RegistrationData? data,
    RegistrationStatus? status,
    String? errorMessage,
    String? applicationNumber,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      applicationNumber: applicationNumber ?? this.applicationNumber,
    );
  }

  @override
  List<Object?> get props => [currentStep, data, status, errorMessage, applicationNumber];
}
