import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:mobile_pager_flutter/features/pager/domain/repositories/i_pager_repository.dart';

class PagerState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  PagerState({this.isLoading = false, this.errorMessage, this.successMessage});

  PagerState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return PagerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class PagerNotifier extends StateNotifier<PagerState> {
  final IPagerRepository _repository;

  PagerNotifier(this._repository) : super(PagerState());

  Future<void> createPager({
    required String merchantId,
    String? label,
    Map<String, dynamic>? metadata,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.createTemporaryPager(
        merchantId: merchantId,
        label: label,
        metadata: metadata,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Pager created successfully',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Create a pager with an invoice image URL (from R2 upload)
  Future<void> createPagerWithImage({
    required String merchantId,
    String? label,
    String? invoiceImageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.createTemporaryPager(
        merchantId: merchantId,
        label: label,
        invoiceImageUrl: invoiceImageUrl,
        metadata: metadata,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Pager created successfully',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> activatePager({
    required String pagerId,
    required String customerId,
    required String customerType,
    required Map<String, dynamic> customerInfo,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.activatePager(
        pagerId: pagerId,
        customerId: customerId,
        customerType: customerType,
        customerInfo: customerInfo,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Pager activated successfully',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updatePagerStatus({
    required String pagerId,
    required PagerStatus status,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updatePagerStatus(pagerId: pagerId, status: status);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Pager status updated',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteTempPager(String pagerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteTemporaryPager(pagerId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Temporary pager deleted',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
