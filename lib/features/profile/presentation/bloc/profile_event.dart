part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final User user;
  UpdateProfileEvent({required this.user});
}
