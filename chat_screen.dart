import 'package:flutter/material.dart';
import 'package:flutter_chat/controller/chat_controller.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../model/message.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  Color black = const Color(0xFF191919);
  Color white = Colors.white;
  Color de = const Color(0xFF319D86);

  TextEditingController msgInputController = TextEditingController();
  late Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState(){
    socket = io(
        'http://localhost:8000',
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build()
    );
    socket.connect();
    setUpSocketListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Container(
        child: Column(
          children: [
            Expanded(
                child: Obx(
                      ()=> Container(
                    padding: const EdgeInsets.all(10),
                    child: Text("Connected User : ${chatController.connectedUser} ",
                      style: TextStyle(
                        color: white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                )),
            Expanded(
              flex: 9,
              child: Obx(
                    ()=> ListView.builder(
                  itemCount: chatController.chatMessages.length,
                  itemBuilder: (context, index){
                    var currentItem = chatController.chatMessages[index];
                    return MessageItem(
                      sentByMe: currentItem.sentByMe == socket.id,
                      message: currentItem.message,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  style: TextStyle(color: white),
                  cursorColor: de,
                  controller: msgInputController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: de),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: de,
                        ),
                        child: IconButton(
                          onPressed: () {
                            sendMessage(msgInputController.text);
                            msgInputController.text = "";
                          },
                          icon: Icon(Icons.send, color: white,),
                        ),
                      )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) {
    var messageJson = {
      "message":text,
      "sentByMe":socket.id
    };
    socket.emit('message',messageJson);
    chatController.chatMessages.add(Message.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data){
      print(data);
      chatController.chatMessages.add(Message.fromJson(data));
    });
    socket.on('connected-user', (data){
      print(data);
      chatController.connectedUser.value = data;
    });
  }

}


class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.sentByMe, required this.message}) : super(key: key);
  final bool sentByMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    Color black = const Color(0xFF191919);
    Color white = Colors.white;
    Color de = const Color(0xFF319D86);
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10,),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sentByMe ? de : white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              style: TextStyle(
                color: sentByMe ? white : de,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 5,),
            Text(
              "9:00 PM",
              style: TextStyle(
                color: (sentByMe ? white : de).withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


