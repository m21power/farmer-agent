part of 'help_bloc.dart';

sealed class HelpEvent {
  const HelpEvent();
}

// class GetHistoryEvent extends HelpEvent {
//   const GetHistoryEvent();
// }

class AskEvent extends HelpEvent {
  final String imagePath;
  const AskEvent({required this.imagePath});
}

// class DeleteHistoryEvent extends HelpEvent {
//   final int id;
//   const DeleteHistoryEvent({required this.id});
// }

class SaveHistoryEvent extends HelpEvent {
  final HistoryModel history;
  const SaveHistoryEvent({required this.history});
}

class UpdateStateEvent extends HelpEvent {}
