import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/notification/domain/usecases/get_unread_count.dart';

/// Lightweight cubit that tracks the unread notification count.
/// Used by the shell to display a badge on the notifications icon.
class UnreadCountCubit extends Cubit<UnreadCountState> {
  UnreadCountCubit({required this.getUnreadCount})
      : super(const UnreadCountState(count: 0));

  final GetUnreadCount getUnreadCount;

  Future<void> loadUnreadCount() async {
    final result = await getUnreadCount(NoParams());
    result.fold(
      (_) {},
      (count) => emit(UnreadCountState(count: count)),
    );
  }

  /// Resets to zero. Called on logout to clear stale session data.
  void reset() => emit(const UnreadCountState(count: 0));

  /// Optimistic decrement when a single notification is marked as read.
  void decrement() {
    if (state.count > 0) {
      emit(UnreadCountState(count: state.count - 1));
    }
  }

  /// Sync the count from a freshly loaded notifications list.
  /// Called when the notification page loads so the badge stays accurate
  /// even if the dedicated unread-count endpoint returns stale data.
  void syncCount(int count) {
    if (state.count != count) {
      emit(UnreadCountState(count: count));
    }
  }

  /// Reset to zero when all notifications are marked as read.
  void clear() {
    emit(const UnreadCountState(count: 0));
  }
}

class UnreadCountState extends Equatable {
  const UnreadCountState({required this.count});

  final int count;

  @override
  List<Object?> get props => [count];
}
