import 'package:flutter/material.dart';

import 'app.dart';
import 'services/theme_service.dart';
import 'services/theme_service_hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The StorageServiceHive constructor requires a box name, the others do not.

  // The box name is just a file name for the file that stores the settings.
  final StorageService store = StorageServiceHive('storage');
  // Initialize the storage service.
  await store.init();
  runApp(MyApp(storage: store));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.storage});
  final StorageService storage;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Hive WASM Test', store: storage),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.store});
  final String title;
  final StorageService store;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _intCounter;
  double? _doubleCounter;
  int? _loadIntCounter;
  double? _loadDoubleCounter;
  int? _notUsed1;
  double? _notUsed2;

  Future<void> _incrementCounter() async {
    setState(() {
      _intCounter = (_intCounter ?? 0) + 1;
      _doubleCounter = (_doubleCounter ?? 0) + 0.1;
    });
    await widget.store.save(App.keyInt, _intCounter);
    await widget.store.save(App.keyDouble, _doubleCounter);
  }

  Future<void> _loadCounters() async {
    _notUsed1 = await widget.store.load(App.keyNotUsed1, App.notUsed1Default);
    _notUsed2 = await widget.store.load(App.keyNotUsed2, App.notUsed2Default);
    _loadIntCounter = await widget.store.load(App.keyInt, App.intDefault);
    _loadDoubleCounter =
        await widget.store.load(App.keyDouble, App.doubleDefault);
    setState(() {
      _intCounter = _loadIntCounter;
      _doubleCounter = _loadDoubleCounter;
    });
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
            const Text('Counters:'),
            Text('int $_intCounter'),
            Text('double $_doubleCounter'),
            const Text('Last load Counters:'),
            Text('notUsed1 $_notUsed1'),
            Text('notUsed2 $_notUsed2'),
            Text('int $_loadIntCounter'),
            Text('double $_loadDoubleCounter'),
            FilledButton(
              onPressed: _loadCounters,
              child: const Text('Load Counters'),
            ),
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
