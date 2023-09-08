import 'package:get_it/get_it.dart';

import '../../repositories/remote_config_repository.dart';

GetIt repositoryLocator = GetIt.instance;

Future<void> setupRepositoryLocator() async {
  repositoryLocator.registerLazySingleton<RemoteConfigRepository>(RemoteConfigRepository.new);

  await repositoryLocator<RemoteConfigRepository>().init();
}
