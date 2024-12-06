import 'package:flutter/material.dart';

import 'app.dart';
import 'services/storage_service.dart';
import 'services/storage_service_hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The box name is just a file name for the file that stores the settings.
  // The name is not used in the WEB implementation where IndexedDB is used.
  final StorageService store = StorageServiceHive('storage');
  // Initialize the storage service.
  await store.init();
  runApp(MyApp(storage: store));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.storage});
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: App.isRunningWithWasm
            ? ColorScheme.fromSeed(seedColor: Colors.red)
            : ColorScheme.fromSeed(seedColor: Colors.green),
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
  int _intCounter = 0;

  double? _doubleWholeCounterNullable;
  double _doubleWholeCounter = 0.0;

  double? _doubleCounterNullable;
  double _doubleCounter = 0.0;

  double? _doubleAlwaysNull;

  int? _loadIntCounterNullable;
  int _loadIntCounter = 0;

  double? _loadDoubleWholeCounterNullable;
  double _loadDoubleWholeCounter = 0.0;

  double? _loadDoubleCounterNullable;
  double _loadDoubleCounter = 0.0;

  Future<void> _incrementCounters() async {
    setState(() {
      _intCounterNullable = (_intCounterNullable ?? 0) + 1;
      _intCounter = _intCounter + 1;
      _doubleWholeCounterNullable = (_doubleWholeCounterNullable ?? 0) + 1;
      _doubleWholeCounter = _doubleWholeCounter + 1;
      _doubleCounterNullable = (_doubleCounterNullable ?? 0) + 0.1;
      _doubleCounter = _doubleCounter + 0.1;
    });
    await widget.store.save(App.keyInt, _intCounter);
    await widget.store.save(App.keyIntNullable, _intCounterNullable);
    //
    await widget.store.save(App.keyDoubleWhole, _doubleWholeCounter);
    await widget.store
        .save(App.keyDoubleWholeNullable, _doubleWholeCounterNullable);

    //
    await widget.store.save(App.keyDouble, _doubleCounter);
    await widget.store.save(App.keyDoubleNullable, _doubleCounterNullable);
    //
    await widget.store.save(App.keyDoubleAlwaysNull, _doubleAlwaysNull);
  }

  Future<void> _loadCounters() async {
    // Load the tested counters of int, int? types.
    _loadIntCounter = await widget.store.load(App.keyInt, App.intDefault);
    _loadIntCounterNullable =
        await widget.store.load(App.keyIntNullable, App.intDefaultNullable);
    // Load the tested counters of double and double? whole number types.
    _loadDoubleWholeCounter =
        await widget.store.load(App.keyDoubleWhole, App.doubleWholeDefault);
    _loadDoubleWholeCounterNullable = await widget.store
        .load(App.keyDoubleWholeNullable, App.doubleWholeNullableDefault);
    // Load the tested counters of double and double? types.
    _loadDoubleCounter =
        await widget.store.load(App.keyDouble, App.doubleDefault);
    _loadDoubleCounterNullable = await widget.store
        .load(App.keyDoubleNullable, App.doubleDefaultNullable);
    // Just to check, always load a null double value.
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
            const Text('\nValues:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('A: int = $_intCounter'),
            Text('B: int nullable = $_intCounterNullable'),
            Text('C: double whole $_doubleWholeCounter'),
            Text('D: double whole nullable = $_doubleWholeCounterNullable'),
            Text('E: double $_doubleCounter'),
            Text('F: double nullable = $_doubleCounterNullable'),
            const Text('\nLast loaded values:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('A: int = $_loadIntCounter'),
            Text('B: int nullable = $_loadIntCounterNullable'),
            Text('C: double whole = $_loadDoubleWholeCounter'),
            Text('D: double whole nullable = $_loadDoubleWholeCounterNullable'),
            Text('E: double = $_loadDoubleCounter'),
            Text('F: double nullable = $_loadDoubleCounterNullable'),
            Text('NULL: double null = $_doubleAlwaysNull\n'),
            SizedBox(
              width: 300,
              child: FilledButton(
                onPressed: _incrementCounters,
                child: const Text('Increase values and save to DB'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 300,
              child: OutlinedButton(
                onPressed: _loadCounters,
                child: const Text('Load values from DB'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
