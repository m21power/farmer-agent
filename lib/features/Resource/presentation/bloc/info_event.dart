part of 'info_bloc.dart';

sealed class InfoEvent {
  const InfoEvent();
}

final class GetInfoEvent extends InfoEvent {
  const GetInfoEvent();
}
