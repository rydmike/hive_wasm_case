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
      home: MyHomePage(
          title: 'HiveCE IndexedDB test${App.buildType}', store: storage),
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
  int? _intCounterNullable;
  double? _doubleCounterNullable;
  int _intCounter = 0;
  double _doubleCounter = 0.0;
  double? _doubleAlwaysNull;

  int? _loadIntCounterNullable;
  double? _loadDoubleCounterNullable;
  int _loadIntCounter = 0;
  double _loadDoubleCounter = 0.0;

  Future<void> _incrementCounter() async {
    setState(() {
      _intCounterNullable = (_intCounterNullable ?? 0) + 1;
      _doubleCounterNullable = (_doubleCounterNullable ?? 0) + 0.1;
      _intCounter = _intCounter + 1;
      _doubleCounter = _doubleCounter + 0.1;
    });
    await widget.store.save(App.keyIntNullable, _intCounterNullable);
    await widget.store.save(App.keyDoubleNullable, _doubleCounterNullable);
    await widget.store.save(App.keyDoubleAlwaysNull, _doubleAlwaysNull);
    await widget.store.save(App.keyInt, _intCounter);
    await widget.store.save(App.keyDouble, _doubleCounter);
  }

  Future<void> _loadCounters() async {
    // Load the tested counters of int, int?, double and double? types.
    _loadIntCounter = await widget.store.load(App.keyInt, App.intDefault);
    _loadIntCounterNullable =
        await widget.store.load(App.keyIntNullable, App.intDefaultNullable);
    //
    _loadDoubleCounter =
        await widget.store.load(App.keyDouble, App.doubleDefault);
    _loadDoubleCounterNullable = await widget.store
        .load(App.keyDoubleNullable, App.doubleDefaultNullable);
    _doubleAlwaysNull = await widget.store
        .load(App.keyDoubleAlwaysNull, App.doubleDefaultAlwaysNull);

    setState(() {
      _intCounterNullable = _loadIntCounterNullable;
      _doubleCounterNullable = _loadDoubleCounterNullable;
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('\nValues:\nHit (+) to change and save values.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('int nullable = $_intCounterNullable'),
            Text('double nullable = $_doubleCounterNullable'),
            Text('int = $_intCounter'),
            Text('double $_doubleCounter'),
            const Text('\nLast load values:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('int nullable = $_loadIntCounterNullable'),
            Text('double nullable = $_loadDoubleCounterNullable'),
            Text('int = $_loadIntCounter'),
            Text('double = $_loadDoubleCounter'),
            Text('double null = $_doubleAlwaysNull\n'),
            FilledButton(
              onPressed: _loadCounters,
              child: const Text('Load Values from DB'),
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
