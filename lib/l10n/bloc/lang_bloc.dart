import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:maize_guard/dependency_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'lang_event.dart';
part 'lang_state.dart';

class LangBloc extends Bloc<LangEvent, LangState> {
  LangBloc() : super(LangInitial()) {
    on<ChangeLangEvent>((event, emit) async {
      await sl<SharedPreferences>().setString('langCode', event.langCode);
      emit(GetLangSuccess(event.langCode));
    });

    on<GetLangEvent>((event, emit) async {
      var langCode = sl<SharedPreferences>().getString('langCode');
      emit(GetLangSuccess(langCode ?? 'en'));
    });
  }
}
