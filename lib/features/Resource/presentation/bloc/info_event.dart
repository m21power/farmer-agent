part of 'info_bloc.dart';

sealed class InfoEvent {
  const InfoEvent();
}

final class GetInfoEvent extends InfoEvent {
  const GetInfoEvent();
}

final class AddDiseaseEvent extends InfoEvent {
  final Disease disease;

  const AddDiseaseEvent(this.disease);
}

final class UpdateDiseaseEvent extends InfoEvent {
  final Disease disease;

  const UpdateDiseaseEvent(this.disease);
}

final class DeleteDiseaseEvent extends InfoEvent {
  final String id;

  const DeleteDiseaseEvent(this.id);
}
