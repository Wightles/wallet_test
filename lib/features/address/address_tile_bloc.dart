import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_test/features/address/address_repository.dart';

class AddressTileEvent {}

class CopyTapped extends AddressTileEvent {
  const CopyTapped(this.address);

  final String address;
}

class ResetCopied extends AddressTileEvent {
  const ResetCopied();
}

class AddressTileState {
  const AddressTileState({
    this.copied = false,
    this.error,
  });

  final bool copied;
  final String? error;

  AddressTileState copyWith({
    bool? copied,
    String? error,
  }) {
    return AddressTileState(
      copied: copied ?? this.copied,
      error: error,
    );
  }
}

class AddressTileBloc extends Bloc<AddressTileEvent, AddressTileState> {
  AddressTileBloc({
    required IAddressRepository repository,
  })  : _repository = repository {
    on<CopyTapped>(_onCopyTapped);
    on<ResetCopied>(_onResetCopied);
  }

  final IAddressRepository _repository;
  Timer? _resetTimer;

  Future<void> _onCopyTapped(
    CopyTapped event,
    Emitter<AddressTileState> emit,
  ) async {
    emit(const AddressTileState());

    try {
      await _repository.copyAddress(event.address);

      emit(const AddressTileState(copied: true));

      _resetTimer?.cancel();
      _resetTimer = Timer(
        const Duration(milliseconds: 1500),
        () => add(const ResetCopied()),
      );
    } catch (_) {
      emit(const AddressTileState(error: 'copy_failed'));
    }
  }

  Future<void> _onResetCopied(
    ResetCopied event,
    Emitter<AddressTileState> emit,
  ) async {
    emit(const AddressTileState());
  }
}
