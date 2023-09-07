import 'package:get_it/get_it.dart';

import '../../repositories/remote_config_repository.dart';

GetIt repositoryLocator = GetIt.instance;

void setupRepositoryLocator() {
  repositoryLocator.registerLazySingleton<RemoteConfigRepository>(RemoteConfigRepository.new);
}
