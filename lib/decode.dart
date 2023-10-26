import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'model/file_media.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
// This is the theme of your application.
//
// TRY THIS: Try running your application with "flutter run". You'll see
// the application has a blue toolbar. Then, without quitting the app,
// try changing the seedColor in the colorScheme below to Colors.green
// and then invoke "hot reload" (save your changes or press the "hot
// reload" button in a Flutter-supported IDE, or press "r" if you used
// the command line to start the app).
//
// Notice that the counter didn't reset back to zero; the application
// state is not lost during the reload. To reset the state, use hot
// restart instead.
//
// This works for code too, not just values: Most code changes can be
// tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  initState() {
    // decodeFile();
    // loadAllFile();
    super.initState();
  }

  Future<void> pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      final url = Uri.parse('http://192.168.101.157:3000/upload');

      try {
        final request = http.MultipartRequest('POST', url);
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        final response = await request.send();
        decodeFile();
        if (response.statusCode == 200) {
          // Xử lý phản hồi từ máy chủ
        } else {
          // Xử lý lỗi
          throw Exception('Failed to upload file');
        }
      } catch (error) {
        // Xử lý lỗi
        throw Exception('Failed to upload file: $error');
      }
    } else {
      // Xử lý người dùng không lựa chọn tệp
    }
  }

  Future<void> decodeFile() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.101.157:3000/convert'),
      );
    } catch (e) {
      print(e);
    }
    // if (response.statusCode == 200) {
    //   final outputBytes = response.bodyBytes;
    //   // Use the output bytes
    // } else {
    //   throw Exception('Failed to convert Anki deck');
    // }
  }

  Future<void> remoteFile() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.101.157:3000/remove'),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadAllFile() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.101.157:3000/files'),
      );
      if (response.statusCode == 200) {
        FileMedia fileMedia = FileMedia.fromJson(jsonDecode(response.body));
        fileMedia.files?.forEach((element) {
          downloadFileFromServer(element ?? '');
        });
        remoteFile();
        // Use the output bytes
      } else {
        throw Exception('Failed to convert Anki deck');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> downloadFileFromServer(String filename) async {
    final url = Uri.parse('http://192.168.101.157:3000/files/$filename');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory?.path}/$filename';
        final File file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);
      } else {
        // Xử lý lỗi
        throw Exception('Failed to download file');
      }
    } catch (error) {
      // Xử lý lỗi
      throw Exception('Failed to download file: $error');
    }
  }

  // final response = await http.post(
  //   Uri.parse('http://192.168.101.157:3000/convert'),
  //   headers: {'Content-Type': 'multipart/form-data'},
  //   // body: {
  //   //   'inputFile': http.MultipartFile.fromBytes(
  //   //     'inputFile',
  //   //     await File('assets/jp_core_2000_1.apkg').readAsBytes(),
  //   //     filename: 'file.apkg',
  //   //   )
  //   // },
  // );
  //
  // if (response.statusCode == 200) {
  //   final outputBytes = response.bodyBytes;
  //   // Use the output bytes
  // } else {
  //   throw Exception('Failed to convert Anki deck');
  // }

  void _incrementCounter() {
    // downloadFileFromServer('1000BEW_B01_U01_001.example.mp3');
    loadAllFile();
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // const Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            InkWell(
              onTap: () {
                pickAndUploadFile();
              },
              child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(
                    child: Text(
                  'PickFile',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                )),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                pickAndUploadFile();
              },
              child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(
                    child: Text(
                  'ConvertFile',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                )),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
