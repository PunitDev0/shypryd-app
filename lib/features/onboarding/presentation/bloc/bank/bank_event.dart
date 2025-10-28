abstract class BankEvent {}

class BankNameChanged extends BankEvent {
  final String bankName;
  BankNameChanged(this.bankName);
}

class AccountNumberChanged extends BankEvent {
  final String accountNumber;
  AccountNumberChanged(this.accountNumber);
}

class ConfirmAccountNumberChanged extends BankEvent {
  final String confirmAccountNumber;
  ConfirmAccountNumberChanged(this.confirmAccountNumber);
}

class IfscCodeChanged extends BankEvent {
  final String ifscCode;
  IfscCodeChanged(this.ifscCode);
}

class SubmitBankDetails extends BankEvent {
  final String bankName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  SubmitBankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.confirmAccountNumber,
    required this.ifscCode,
  });
}
