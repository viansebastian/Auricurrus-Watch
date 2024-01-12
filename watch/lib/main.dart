import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  // both connection methods work when workinig with Edge
  final IO.Socket socket = IO.io('http://10.0.2.2:3001', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  // final IO.Socket socket = IO.io(
  //     'http://localhost:3001',
  //     IO.OptionBuilder()
  //         .setTransports(['websocket'])
  //         .disableAutoConnect()
  //         .build());

  TextEditingController messageController = TextEditingController();
  List<String> messages = [];
  late UniqueKey _key;

  @override
  void initState() {
    super.initState();
    _key = UniqueKey();
    connectServer();
    receiveMessage();
    debugPrint('hello');
  }

  void connectServer() {
    socket.connect();
    socket.onConnect((_) {
      debugPrint('connected to server blabla');
    });
    socket.on('connect_error', (data) {
      debugPrint('Error connecting to server: $data');
    });
  }

  void receiveMessage() {
    socket.on('response', (data) {
      setState(() {
        messages.add(data['dir']);
      });
      debugPrint(data['dir']);
    });
  }

  Future<void> onRefresh() async {
    // Clear the messages list on refresh
    setState(() {
      messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Flutter Socket.IO Chat'),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
