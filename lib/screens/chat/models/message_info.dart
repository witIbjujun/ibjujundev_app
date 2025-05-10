class MessageInfo {
  MessageInfo({
    this.chatId = '',
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
    this.anwCode = '',
    this.messageId = '',
    this.targetView = '',
    this.categoryNm = '',
    this.reqName = '',
    this.estimateAmount = '',
    this.reqUser = '',

  });

  String chatId;
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
  String anwCode;
  String messageId;
  String targetView;
  String categoryNm;
  String reqName;
  String estimateAmount;
  String reqUser;

  List<MessageInfo>? parseMessageList(List<dynamic> messageList) {
    return messageList.map((messageInfo) {
      return MessageInfo(
          chatId: messageInfo['chatId'] ?? '',
          roomNm: messageInfo['roomNm'] ?? '',
          author: messageInfo['author'] ?? '',
          id: messageInfo['id'] ?? '',
          text: messageInfo['text'] ?? '',
          status: messageInfo['status'] ?? '',
          imageUrl: messageInfo['imageUrl'] ?? '',
          chatgubun: messageInfo['chatgubun'] ?? '',
          type: messageInfo['type'] ?? '',
          time: messageInfo['time'] ?? '',
          anwCode: messageInfo['anwCode'] ?? '',
          messageId: messageInfo['messageId'] ?? '',
          targetView: messageInfo['targetView'] ?? '',
          categoryNm: messageInfo['categoryNm'] ?? '',
          reqName: messageInfo['reqName'] ?? '',
          estimateAmount: messageInfo['estimateAmount'] ?? '',
          reqUser: messageInfo['reqUser'] ?? '',
          storeName: messageInfo['storeName'] ?? ''
      );
    }).toList();
  }

  // ✅ 2025-03-29: toJson 추가
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'text': text,
      'date': time,
      'chatgubun': chatgubun ,
      'userName': author,
      'type': type,
      'time': time,
      'storeName': storeName,
      'profileImage': imageUrl,
      'messageId': messageId,
      'anwCode': anwCode,
      'targetView': targetView,
      'categoryNm': categoryNm,
      'reqName': reqName,
      'estimateAmount': estimateAmount,
      'reqUser': reqUser,

    };
  }
}
