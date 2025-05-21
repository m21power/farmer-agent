part of 'info_bloc.dart';

sealed class InfoState extends Equatable {
  const InfoState();

  @override
  List<Object> get props => [];
}

final class InfoInitial extends InfoState {}

final class InfoLoadingState extends InfoState {}

final class InfoSuccessState extends InfoState {
  final String message;
  final List<Disease> info;
  const InfoSuccessState({required this.message, required this.info});

  @override
  List<Object> get props => [message, info];
}

final class InfoErrorState extends InfoState {
  final String message;
  const InfoErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
