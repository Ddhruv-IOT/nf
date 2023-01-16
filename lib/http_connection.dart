import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Client> createClient(String ip, String title) async {
  final response = await http.post(
    Uri.parse('http://$ip:8000'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Client.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create Client.');
  }
}

class Client {
  final int id;
  final String title;

  const Client({required this.id, required this.title});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      title: json['title'],
    );
  }
}

class HttpApp extends StatefulWidget {
  final String ipAddr;
  const HttpApp({super.key, required this.ipAddr});

  @override
  State<HttpApp> createState() {
    return _HttpAppState();
  }
}

late String ip;

class _HttpAppState extends State<HttpApp> {
  final TextEditingController _controller = TextEditingController();
  Future<Client>? _futureClient;
  @override
  void initState() {
    super.initState();
    ip = widget.ipAddr;
    debugPrint(ip);
  }

  late String ipAddr;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Data Example'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureClient == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter Title'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureClient = createClient(ip, _controller.text);
            });
          },
          child: const Text('Create Data'),
        ),
      ],
    );
  }

  FutureBuilder<Client> buildFutureBuilder() {
    return FutureBuilder<Client>(
      future: _futureClient,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.title);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
