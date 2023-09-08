import 'dart:async';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_centralized_exception_handler_example/dependencies/error_handler_context_locator.dart';
import 'package:flutter_centralized_exception_handler_example/dependencies/repository_locator.dart';
import 'package:flutter_centralized_exception_handler_example/exceptions/app_exception_code.dart';
import 'package:flutter_centralized_exception_handler_example/helpers/app_exception_codes.dart';
import 'package:flutter_centralized_exception_handler_example/models/crashlytics_error_status_enum.dart';

import 'helpers/app_error_handler.dart';

void main() {
  return runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await setupRepositoryLocator();

    FlutterError.onError = (details) async {
      FlutterError.presentError(details);
      reportErrorDetails(details);

      final errorStatus = getCrashlyticsErrorStatus(details.exception);
      if (kIsWeb || errorStatus.shouldNotReport) return;
      return FirebaseCrashlytics.instance.recordFlutterError(details, fatal: errorStatus.isFatal);
    };

    if (!kIsWeb) {
      Isolate.current.addErrorListener(RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        final stackTrace = StackTrace.fromString(errorAndStacktrace.last.toString());
        return FirebaseCrashlytics.instance.recordError(errorAndStacktrace.first, stackTrace);
      }).sendPort);
    }

    runApp(const MyApp());
  }, (error, stackTrace) async {
    if (kDebugMode) debugPrint('Unhandled Error: $error StackTrace: $stackTrace');
    reportErrorToUI(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    registerErrorHandlerContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Error handler'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              ElevatedButton(
                child: const Text('NullPointer'),
                onPressed: () {
                  const nullVal = null;
                  nullVal!.toString();
                },
              ),
              ElevatedButton(
                child: const Text('DioExceptionTimeout'),
                onPressed: () => throw DioException.connectionTimeout(
                  timeout: const Duration(seconds: 1),
                  requestOptions: RequestOptions(),
                ),
              ),
              ElevatedButton(
                child: const Text('DioExceptionUnknown'),
                onPressed: () => throw DioException(
                  type: DioExceptionType.unknown,
                  requestOptions: RequestOptions(),
                ),
              ),
              ElevatedButton(
                child: const Text('DioException400Unparsed'),
                onPressed: () => throw DioException(
                    type: DioExceptionType.badResponse,
                    requestOptions: RequestOptions(),
                    response: Response(
                      requestOptions: RequestOptions(),
                      data: {
                        'detail': {'error': '[UNMAPPED_CODE] Unparsed response error message'}
                      },
                    )),
              ),
              ElevatedButton(
                child: const Text('DioException400Parsed'),
                onPressed: () => throw DioException(
                    type: DioExceptionType.badResponse,
                    requestOptions: RequestOptions(),
                    response: Response(
                      requestOptions: RequestOptions(),
                      data: {
                        'detail': {'error': '[MAPPED_CODE] Crazy XYZ will not show'}
                      },
                    )),
              ),
              ElevatedButton(
                child: const Text('CheckInternet'),
                onPressed: () => throw const AppExceptionCode(code: kCheckInternetConnectionErrorKey),
              ),
              ElevatedButton(
                child: const Text('Exception'),
                onPressed: () => throw Exception(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
