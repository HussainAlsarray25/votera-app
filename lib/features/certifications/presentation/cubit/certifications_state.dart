part of 'certifications_cubit.dart';

abstract class CertificationsState extends Equatable {
  const CertificationsState();

  @override
  List<Object?> get props => [];
}

class CertificationsInitial extends CertificationsState {
  const CertificationsInitial();
}

class CertificationsLoading extends CertificationsState {
  const CertificationsLoading();
}

class CertificationLoaded extends CertificationsState {
  const CertificationLoaded({required this.certification});

  final CertificationEntity certification;

  @override
  List<Object?> get props => [certification];
}

class CertificationsError extends CertificationsState {
  const CertificationsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
