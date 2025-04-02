class MessageInfo {
  MessageInfo({
    this.roomId = '',
    this.roomNm = '',
    this.author = '',
    this.id = '',
    this.text = '',
    this.status = '',
    this.type = '',
    this.chatgubun = '',
    this.imageUrl = '',
    this.time = '',
    this.storeName = '',


  });

  String roomId;
  String roomNm;
  String author;
  String id;
  String text;
  String status;
  String type;
  String chatgubun;
  String imageUrl;
  String time;
  String storeName;


  List<MessageInfo>? parseMessageList(List<dynamic> messageList) {
    return messageList.map((messageInfo) {
      return MessageInfo(
          roomId: messageInfo['roomId'] ?? '',
          roomNm: messageInfo['roomNm'] ?? '',
          author: messageInfo['author'] ?? '',
          id: messageInfo['id'] ?? '',
          text: messageInfo['text'] ?? '',
          status: messageInfo['status'] ?? '',
          imageUrl: messageInfo['imageUrl'] ?? '',
          chatgubun: messageInfo['chatgubun'] ?? '',
          type: messageInfo['type'] ?? '',
          time: messageInfo['time'] ?? '',
          storeName: messageInfo['storeName'] ?? ''
      );
    }).toList();
  }

  // ✅ 2025-03-29: toJson 추가
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': time,
      'chatgubun': chatgubun ,
      'userName': author,
      'type': type,
      'time': time,
      'storeName': storeName,
      'profileImage': imageUrl,
    };
  }
}
