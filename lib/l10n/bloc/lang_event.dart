part of 'lang_bloc.dart';

sealed class LangEvent {
  const LangEvent();
}

class ChangeLangEvent extends LangEvent {
  final String langCode;

  const ChangeLangEvent(this.langCode);
}

class GetLangEvent extends LangEvent {
  const GetLangEvent();
}
