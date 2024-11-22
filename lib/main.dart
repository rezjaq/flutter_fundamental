import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fundamental/pages/pizza.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  List<Pizza> myPizzas = [];
  int appCounter = 0;
  String documentPath = '';
  String tempPath = '';
  late File myFile;
  String fileText = '';
  final pwdController = TextEditingController();
  String myPass = '';
  final storage = const FlutterSecureStorage();
  final myKey = 'myPass';

  Future writeToSecureStorage() async {
    await storage.write(key: myKey, value: pwdController.text);
  }

  Future<String> readFromSecureStorage() async {
    String secret = await storage.read(key: myKey) ?? '';
    return secret;
  }

  Future<bool> readFile() async {
    try {
      await myFile.writeAsString('Margherita, Capricciosa, napoli');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Fungsi untuk mendapatkan path direktori
  Future getPath() async {
    final docDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();

    // Update state dengan path direktori
    setState(() {
      documentPath = docDir.path;
      tempPath = tempDir.path;
    });
  }

  // Fungsi untuk membaca dan menulis SharedPreferences
  Future readAndWritePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      appCounter = prefs.getInt('appCounter') ?? 0;
      appCounter++;
      prefs.setInt('appCounter', appCounter);
    });
  }

  // Fungsi untuk menghapus SharedPreferences
  Future deletePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      appCounter = 0;
    });
  }

  // Fungsi untuk membaca file JSON dari assets
  Future<List<Pizza>> readJsonFile() async {
    String myString = await DefaultAssetBundle.of(context)
        .loadString('assets/pizzalist.json');
    List<dynamic> pizzaMapList = jsonDecode(myString);
    List<Pizza> myPizzas = [];
    for (var pizza in pizzaMapList) {
      myPizzas.add(Pizza.fromJson(pizza));
    }
    String json = convertToJSON(myPizzas);
    print(json);
    return myPizzas;
  }

  // Fungsi untuk mengonversi list Pizza ke JSON
  String convertToJSON(List<Pizza> pizzas) {
    return jsonEncode(pizzas.map((pizza) => pizza.toJson()).toList());
  }

  @override
  void initState() {
    super.initState();
    getPath();
    // readAndWritePreference();
    // readJsonFile().then((value) {
    //   setState(() {
    //     myPizzas = value;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Path Provider'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: pwdController,
              ),
              ElevatedButton(
                child: const Text('save value'),
                onPressed: () {
                  writeToSecureStorage();
                },
              ),
              ElevatedButton(
                child: const Text('read value'),
                onPressed: () {
                  readFromSecureStorage().then((value) {
                    setState(() {
                      myPass = value;
                    });
                  });
                },
              ),
              Text(myPass),
            ],
          ),
        ),
      ),
      // body: Container(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: [
      //         Text('You have opened the app $appCounter times.'),
      //         ElevatedButton(
      //           onPressed: () {
      //             deletePreference();
      //           },
      //           child: const Text('Reset counter'),
      //         ),
      //         // Expanded(
      //         //   child: ListView.builder(
      //         //     itemCount: myPizzas.length,
      //         //     itemBuilder: (context, index) {
      //         //       return ListTile(
      //         //         title: Text(myPizzas[index].pizzaName),
      //         //         subtitle: Text(myPizzas[index].description),
      //         //       );
      //         //     },
      //         //   ),
      //         // ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
