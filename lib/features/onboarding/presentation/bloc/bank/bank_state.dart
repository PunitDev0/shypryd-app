abstract class BankState {}

class BankInitial extends BankState {}

class BankLoading extends BankState {}

class BankVerified extends BankState {}

class BankError extends BankState {
  final String message;
  BankError(this.message);
}

class BankDataUpdated extends BankState {
  final String bankName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  BankDataUpdated({
    required this.bankName,
    required this.accountNumber,
    required this.confirmAccountNumber,
    required this.ifscCode,
  });
}
