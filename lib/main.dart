import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'helpers/app_error_handler.dart';

void main() {
  return runZonedGuarded(() {
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
