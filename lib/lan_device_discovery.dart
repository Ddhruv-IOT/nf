import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:net2test/http_connection.dart';
import 'package:network_info_plus/network_info_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<HostModel> _hosts = <HostModel>[];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                findDevices();
              },
              child: const Text('Scan'),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final host = _hosts[index];

                return Card(
                  child: ListTile(
                    title: Text(host.ip),
                    leading: const Icon(Icons.devices),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {
                      debugPrint("Click");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HttpApp(
                            ipAddr: host.ip,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              itemCount: _hosts.length,
            ),
          ],
        ),
      ),
    );
  }

  findDevices() async {
    var wifiIP = await NetworkInfo().getWifiIP();

    var subnet = ipToCSubnet(wifiIP!);
    final scanner = LanScanner(debugLogging: true);

    final stream = scanner.icmpScan(
      subnet,
      progressCallback: (progress) {
        if (kDebugMode) {
          print('progress: $progress');
        }
      },
    );

    stream.listen((HostModel host) {
      setState(() {
        _hosts.add(host);
      });
    });
  }
}
