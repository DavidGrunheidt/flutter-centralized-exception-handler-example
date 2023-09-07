import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

const errorHandlerContextInstanceName = 'errorHandlerContext';

void registerErrorHandlerContext(BuildContext context) {
  GetIt.instance.registerSingleton<BuildContext>(context, instanceName: errorHandlerContextInstanceName);
}

BuildContext getErrorHandlerContext() {
  return GetIt.instance<BuildContext>(instanceName: errorHandlerContextInstanceName);
}
