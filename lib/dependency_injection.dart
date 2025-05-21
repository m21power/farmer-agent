import 'package:get_it/get_it.dart' as get_it;
import 'package:http/http.dart' as http;
import 'package:maize_guard/features/Resource/data/repo/repo_impl.dart';
import 'package:maize_guard/features/Resource/domain/repository/get_info_repo.dart';
import 'package:maize_guard/features/Resource/presentation/bloc/info_bloc.dart';
import 'package:maize_guard/features/auth/domain/repository/auth_repository.dart';
import 'package:maize_guard/features/community/domain/usecases/get_notification_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/post_question_usecase.dart';
import 'package:maize_guard/features/community/domain/usecases/seen_notification_usecase.dart';
import 'package:maize_guard/features/help/data/repository/database.dart';
import 'package:maize_guard/features/help/data/repository/help_repo_impl.dart';
import 'package:maize_guard/features/help/domain/repository/help_repo.dart';
import 'package:maize_guard/features/help/domain/repository/local_repo.dart';
import 'package:maize_guard/features/help/domain/usecases/delete_history_usecase.dart';
import 'package:maize_guard/features/help/domain/usecases/get_history_usecase.dart';
import 'package:maize_guard/features/help/domain/usecases/save_history_usecase.dart';
import 'package:maize_guard/features/help/presentation/bloc/bloc/history_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'core/constant/socket_helper.dart';
import 'core/network/network_info.dart';
import 'features/Resource/domain/usecases/get_info_usecase.dart';
import 'features/auth/data/repository/auth_repo_impl.dart';
import 'features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'features/auth/domain/usecases/log_out_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/community/data/repository/community_repo_impl.dart';
import 'features/community/domain/repository/community_repo.dart';
import 'features/community/domain/usecases/delete_post_usecase.dart';
import 'features/community/domain/usecases/delete_reply_usecase.dart';
import 'features/community/domain/usecases/edit_reply_usecase.dart';
import 'features/community/domain/usecases/get_post_usecase.dart';
import 'features/community/domain/usecases/listen_notification_usecase.dart';
import 'features/community/domain/usecases/listen_question_usecase.dart';
import 'features/community/domain/usecases/post_reply_usecase.dart';
import 'features/community/domain/usecases/update_post_usecase.dart';
import 'features/community/presentation/bloc/community_bloc.dart';
import 'features/help/data/repository/local_repo_impl.dart';
import 'features/help/domain/usecases/ask_usecase.dart';
import 'features/help/presentation/bloc/help_bloc.dart';
import 'features/profile/data/repository/profile_repo_impl.dart';
import 'features/profile/domain/repository/profile_repo.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

final sl = get_it.GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => http.Client());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  // auth
  // repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepoImpl(
        sharedPreferences: sl(),
        networkInfo: sl(),
        client: sl(),
        historyDatabase: sl(),
      ));
  // usecases
  sl.registerLazySingleton(() => LoginUsecase(repository: sl()));
  sl.registerLazySingleton(() => LogOutUsecase(authRepository: sl()));
  sl.registerLazySingleton(() => IsLoggedInUsecase(authRepository: sl()));
  sl.registerLazySingleton(() => SignUpUsecase(authRepository: sl()));
  // bloc
  sl.registerFactory(() => AuthBloc(
        loginUsecase: sl(),
        logOutUsecase: sl(),
        isLoggedInUsecase: sl(),
        signUpUsecase: sl(),
      ));

  //profile
  // repository
  sl.registerLazySingleton<ProfileRepo>(() => ProfileRepoImpl(
        sharedPreferences: sl(),
        networkInfo: sl(),
        client: sl(),
      ));
  // usecases
  sl.registerLazySingleton(() => UpdateProfileUsecase(repository: sl()));
  // bloc
  sl.registerFactory(() => ProfileBloc(
        updateProfileUsecase: sl(),
      ));
  // help
  // repository
  sl.registerLazySingleton<AskRepository>(() => AskRepositoryImpl(
        sharedPreferences: sl(),
        networkInfo: sl(),
        client: sl(),
      ));
  sl.registerLazySingleton<HistoryDatabase>(() => HistoryDatabase.instance);
  //local repo
  sl.registerLazySingleton<LocalRepo>(() => LocalRepoImpl(
        historyDatabase: sl(),
      ));
  // usecases
  sl.registerLazySingleton(() => AskUsecase(askRepository: sl()));
  sl.registerLazySingleton(() => GetHistoryUsecase(localRepo: sl()));
  sl.registerLazySingleton(() => SaveHistoryUsecase(localRepo: sl()));
  sl.registerLazySingleton(() => DeleteHistoryUsecase(localRepo: sl()));
  // bloc
  sl.registerFactory(() => HelpBloc(
        askUsecase: sl(),
        deleteHistoryUsecase: sl(),
        getHistoryUsecase: sl(),
        saveHistoryUsecase: sl(),
      ));
  //socket
  var userId = sl<SharedPreferences>().getString("userid");

  IO.Socket socket = SocketHelper.createSocket(userId ?? "123");
  sl.registerLazySingleton<IO.Socket>(() => socket);
  // community
  // repository
  sl.registerLazySingleton<CommunityRepo>(() => CommunityRepoImpl(
        sharedPreferences: sl(),
        networkInfo: sl(),
        client: sl(),
        socket: sl(),
      ));
  // usecases
  sl.registerLazySingleton(() => GetPostUsecase(communityRepo: sl()));
  sl.registerLazySingleton(() => PostQuestionUsecase(communityRepo: sl()));
  sl.registerLazySingleton(() => PostReplyUsecase(communityRepo: sl()));
  sl.registerLazySingleton(() => GetNotificationUsecase(communityRepo: sl()));
  sl.registerLazySingleton(() => SeenNotificationUsecase(communityRepo: sl()));
  sl.registerLazySingleton(() => DeletePostUsecase(communityRepo: sl()));
  sl.registerLazySingleton(() => UpdatePostUsecase(communityRepo: sl()));
  sl.registerLazySingleton(() => DeleteReplyUsecase(communityRepo: sl()));
  sl.registerLazySingleton(() => EditReplyUsecase(communityRepo: sl()));
  sl.registerLazySingleton(
      () => ListenNotificationUsecase(communityRepo: sl()));
  sl.registerLazySingleton(() => ListenQuestionUsecase(communityRepo: sl()));
  // bloc
  sl.registerFactory(
    () => CommunityBloc(
        getPostUsecase: sl(),
        postQuestionUsecase: sl(),
        postReplyUsecase: sl(),
        getNotificationUsecase: sl(),
        seenNotificationUsecase: sl(),
        deletePostUsecase: sl(),
        updatePostUsecase: sl(),
        deleteReplyUsecase: sl(),
        editReplyUsecase: sl(),
        listenNotificationUsecase: sl(),
        listenQuestionUsecase: sl()),
  );

  //history
  sl.registerFactory<HistoryBloc>(() => HistoryBloc(
        getHistoryUsecase: sl(),
        deleteHistoryUsecase: sl(),
      ));
  //education info
  sl.registerLazySingleton<GetInfoRepository>(
    () => RepoImpl(client: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetInfoUsecase(repository: sl()));
  //bloc
  sl.registerFactory<InfoBloc>(
    () => InfoBloc(getInfoUsecase: sl()),
  );
}
