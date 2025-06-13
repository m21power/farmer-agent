part of 'help_bloc.dart';

sealed class HelpState extends Equatable {
  final List<HistoryModel> history;
  HelpState({required this.history});

  @override
  List<Object> get props => [history];
}

// final class GetHistorySuccessState extends HelpState {
//   final String message;
//   final List<HistoryModel> history;
//   GetHistorySuccessState({required this.message, required this.history})
//       : super(history: history);
//   @override
//   List<Object> get props => [message, history];
// }

// final class GetHistoryLoadingState extends HelpState {
//   GetHistoryLoadingState() : super(history: []);
// }
final class HistoryInitial extends HelpState {
  HistoryInitial() : super(history: []);
}

final class HistoryErrorState extends HelpState {
  final String message;
  HistoryErrorState(
      {required this.message, required List<HistoryModel> history})
      : super(history: history);
  @override
  List<Object> get props => [message, history];
}

final class AskSuccessState extends HelpState {
  final String message;
  final List<HistoryModel> history;
  final isLowProbability;
  AskSuccessState(
      {required this.message,
      required this.history,
      required this.isLowProbability})
      : super(history: history);
  @override
  List<Object> get props => [message, history, isLowProbability];
}

final class UpdateState extends HelpState {
  final String message;
  final List<HistoryModel> history;
  final isLowProbability;
  UpdateState(
      {required this.message,
      required this.history,
      required this.isLowProbability})
      : super(history: history);
  @override
  List<Object> get props => [message, history, isLowProbability];
}

final class AskLoadingState extends HelpState {
  final List<HistoryModel> history;
  AskLoadingState({required this.history}) : super(history: history);
}

// final class DeleteHistorySuccessState extends HelpState {
//   final String message;
//   final List<HistoryModel> history;
//   DeleteHistorySuccessState({required this.message, required this.history})
//       : super(history: history);
//   @override
//   List<Object> get props => [message, history];
// }

final class SaveHistorySuccessState extends HelpState {
  final String message;
  final List<HistoryModel> history;
  SaveHistorySuccessState({required this.message, required this.history})
      : super(history: history);
  @override
  List<Object> get props => [message, history];
}
