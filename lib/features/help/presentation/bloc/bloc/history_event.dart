part of 'history_bloc.dart';

sealed class HistoryEvent {
  const HistoryEvent();
}

final class GetHistoryEvent extends HistoryEvent {
  const GetHistoryEvent();
}

final class DeleteHistoryEvent extends HistoryEvent {
  final int id;
  const DeleteHistoryEvent({required this.id});
}
