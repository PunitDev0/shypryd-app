import 'package:ShipRyd_app/features/onboarding/presentation/bloc/bank/bank_event.dart';
import 'package:ShipRyd_app/features/onboarding/presentation/bloc/bank/bank_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  String bankName = '';
  String accountNumber = '';
  String confirmAccountNumber = '';
  String ifscCode = '';

  BankBloc() : super(BankInitial()) {
    on<BankNameChanged>((event, emit) {
      bankName = event.bankName;
      emit(BankDataUpdated(
        bankName: bankName,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
      ));
    });

    on<AccountNumberChanged>((event, emit) {
      accountNumber = event.accountNumber;
      emit(BankDataUpdated(
        bankName: bankName,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
      ));
    });

    on<ConfirmAccountNumberChanged>((event, emit) {
      confirmAccountNumber = event.confirmAccountNumber;
      emit(BankDataUpdated(
        bankName: bankName,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
      ));
    });

    on<IfscCodeChanged>((event, emit) {
      ifscCode = event.ifscCode;
      emit(BankDataUpdated(
        bankName: bankName,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
      ));
    });

    on<SubmitBankDetails>((event, emit) async {
      emit(BankLoading());
      try {
        if (event.accountNumber != event.confirmAccountNumber) {
          throw Exception('Account numbers do not match');
        }
        await Future.delayed(const Duration(seconds: 1)); // Mock save
        print(
            'Saving Bank details: Bank: ${event.bankName}, Account: ${event.accountNumber}, IFSC: ${event.ifscCode}');
        emit(BankVerified());
      } catch (e) {
        emit(BankError('Failed to save details: $e'));
      }
    });
  }
}
