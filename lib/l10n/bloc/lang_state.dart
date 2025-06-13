part of 'lang_bloc.dart';

sealed class LangState extends Equatable {
  final String? langCode;

  const LangState({this.langCode});

  @override
  List<Object?> get props => [langCode];
}

final class LangInitial extends LangState {
  const LangInitial() : super();
}

final class LangChanged extends LangState {
  const LangChanged(String langCode) : super(langCode: langCode);
}

final class LangError extends LangState {
  final String message;

  const LangError(this.message) : super();

  @override
  List<Object?> get props => [message, langCode];
}

final class GetLangSuccess extends LangState {
  const GetLangSuccess(String langCode) : super(langCode: langCode);
}
