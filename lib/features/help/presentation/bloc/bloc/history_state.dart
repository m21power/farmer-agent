part of 'history_bloc.dart';

sealed class HistoryState extends Equatable {
  final List<HistoryModel> history;
  const HistoryState({required this.history});

  @override
  List<Object> get props => [history];
}

final class HistoryInitial extends HistoryState {
  HistoryInitial() : super(history: []);
}

final class GetHistorySuccessState extends HistoryState {
  final String message;
  const GetHistorySuccessState(
      {required this.message, required List<HistoryModel> history})
      : super(history: history);
  @override
  List<Object> get props => [message, history];
}

final class GetHistoryLoadingState extends HistoryState {
  GetHistoryLoadingState() : super(history: []);
}

final class GetHistoryErrorState extends HistoryState {
  final String message;
  const GetHistoryErrorState(
      {required this.message, required List<HistoryModel> history})
      : super(history: history);
  @override
  List<Object> get props => [message, history];
}

final class DeleteHistorySuccessState extends HistoryState {
  final String message;
  const DeleteHistorySuccessState(
      {required this.message, required List<HistoryModel> history})
      : super(history: history);
  @override
  List<Object> get props => [message, history];
}
