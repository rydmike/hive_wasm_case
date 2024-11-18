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

  int? _loadIntCounterNullable;
  double? _loadDoubleCounterNullable;
  int _loadIntCounter = 0;
  double _loadDoubleCounter = 0.0;

  // int _loadNotUsedInt = 1;
  // double _loadNotUsedDouble = 1.0;
  //
  // Color _loadNotUsedColor = Colors.white;
  // Color? _loadNotUsedNullableColor;
  //
  // ThemeMode _loadThemeMode = ThemeMode.light;

  Future<void> _incrementCounter() async {
    setState(() {
      _intCounterNullable = (_intCounterNullable ?? 0) + 1;
      _doubleCounterNullable = (_doubleCounterNullable ?? 0) + 0.1;
      _intCounter = _intCounter + 1;
      _doubleCounter = _doubleCounter + 0.1;
    });
    await widget.store.save(App.keyIntNullable, _intCounterNullable);
    await widget.store.save(App.keyDoubleNullable, _doubleCounterNullable);
    await widget.store.save(App.keyInt, _intCounter);
    await widget.store.save(App.keyDouble, _doubleCounter);
  }

  Future<void> _loadCounters() async {
    // These type conversions are only here to simulate the actual use case
    // frm the Playground. Where a lot of keys are read, but only some contain
    // exist and contain values.
    // _loadNotUsedInt =
    //     await widget.store.load(App.keyNotUsedInt, App.notUsedIntDefault);
    // _loadNotUsedDouble =
    //     await widget.store.load(App.keyNotUsedDouble, App.notUsedDoubleDefault);

    // _loadNotUsedColor =
    //     await widget.store.load(App.keyNotUsedColor, App.notUsedColorDefault);
    // _loadNotUsedNullableColor = await widget.store
    //     .load(App.keyNotUsedNullableColor, App.notUsedNullableColorDefault);
    //
    // _loadThemeMode =
    //     await widget.store.load(App.keyThemeMode, App.defaultThemeMode);

    // Load the tested counters of int, int?, double and double? types.
    _loadIntCounterNullable =
        await widget.store.load(App.keyIntNullable, App.intDefaultNullable);
    _loadDoubleCounterNullable = await widget.store
        .load(App.keyDoubleNullable, App.doubleDefaultNullable);
    // Doubles
    _loadIntCounter = await widget.store.load(App.keyInt, App.intDefault);
    _loadDoubleCounter =
        await widget.store.load(App.keyDouble, App.doubleDefault);

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
            const Text('\nCounters:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('int nullable = $_intCounterNullable'),
            Text('double nullable = $_doubleCounterNullable'),
            Text('int = $_intCounter'),
            Text('double $_doubleCounter'),
            const Text('\nLast load Counters:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('int nullable = $_loadIntCounterNullable'),
            Text('double nullable = $_loadDoubleCounterNullable'),
            Text('int = $_loadIntCounter'),
            Text('double = $_loadDoubleCounter\n'),
            // const Text('\n'),
            // Text('notUsedInt = $_loadNotUsedInt'),
            // Text('notUsedDouble = $_loadNotUsedDouble'),
            // Text('notUsedColor = $_loadNotUsedColor'),
            // Text('notUsedNullableColor = $_loadNotUsedNullableColor'),
            // Text('notUsedThemeMode = $_loadThemeMode'),
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
