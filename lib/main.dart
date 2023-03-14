import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ObjectProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}

@immutable
class BaseObject {
  final String id;
  final String lastUpdated;

  BaseObject()
      : id = const Uuid().v4(),
        lastUpdated = DateTime.now().toIso8601String();

  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  get hashCode => id.hashCode;
}

@immutable
class ExpensiveObject extends BaseObject {}

@immutable
class CheapObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier {
  late String id;
  late CheapObject _cheapObject;
  late StreamSubscription _cheapObjectStreamSub;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveObjectStreamSub;

  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }

  CheapObject get cheapObject => _cheapObject;

  ExpensiveObject get expensiveObject => _expensiveObject;

  void start() {
    _cheapObjectStreamSub =
        Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _cheapObject = CheapObject();
      notifyListeners();
    });
    _expensiveObjectStreamSub =
        Stream.periodic(const Duration(seconds: 10)).listen((_) {
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }

  void stop() {
    _cheapObjectStreamSub.cancel();
    _expensiveObjectStreamSub.cancel();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
      ),
      body: Column(
        children: [
          Row(
            children: const [
              Expanded(child: CheapWidget()),
              Expanded(child: ExpensiveWidget()),
            ],
          ),
          Row(
            children: const [
              Expanded(child: ObjectProvideWidget()),
            ],
          ),
          Row(children: [
            TextButton(onPressed: (){
              context.read<ObjectProvider>().stop();
            }, child: const Text('Stop')),
            TextButton(onPressed: (){
              context.read<ObjectProvider>().start();
            }, child: const Text('Start')),
          ],),
        ],
      ),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider, CheapObject>(
        (provider) => provider.cheapObject);
    return Container(
      height: 100,
      color: Colors.blue,
      child: Column(
        children: [
          const Text('Cheap widget'),
          const Text('Last updated'),
          Text(cheapObject.lastUpdated),
        ],
      ),
    );
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
        (provider) => provider.expensiveObject);
    return Container(
      height: 100,
      color: Colors.green,
      child: Column(
        children: [
          const Text('Expensive widget'),
          const Text('Last updated'),
          Text(expensiveObject.lastUpdated),
        ],
      ),
    );
  }
}

class ObjectProvideWidget extends StatelessWidget {
  const ObjectProvideWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectProvider>();

    return Container(
      height: 100,
      color: Colors.purpleAccent,
      child: Column(
        children: [
          const Text('Object provider widget'),
          const Text('ID'),
          Text(provider.id),
        ],
      ),
    );
  }
}
