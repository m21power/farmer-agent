part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

// States
class UpdateLoadingState extends ProfileState {}

class UpdateSuccessState extends ProfileState {}

class UpdateFailureState extends ProfileState {
  final String message;
  const UpdateFailureState(this.message);
  @override
  List<Object> get props => [message];
}
