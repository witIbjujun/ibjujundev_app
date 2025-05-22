class MessageInfo {
  MessageInfo({
    this.chatId = '',
    this.roomNm = '',
    this.author = '',
    this.msgCode = '',
    this.id = '',
    this.text = '',
    this.status = '',
    this.type = '',
    this.chatgubun = '',
    this.imageUrl = '',
    this.userImage = '',
    this.time = '',
    this.storeName = '',
    this.anwCode = '',
    this.messageId = '',
    this.targetView = '',
    this.categoryNm = '',
    this.reqName = '',
    this.estimateAmount = '',
    this.reqUser = '',
    this.nextReqState = '',
    this.reqBtenNm = '',
    this.reqStepState = '',
    this.reqStateNm = '',


  });

  String chatId;
  String roomNm;
  String author;
  String id;
  String text;
  String status;
  String type;
  String chatgubun;
  String msgCode;
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
  String nextReqState;
  String reqBtenNm;
  String userImage;
  String reqStepState;
  String reqStateNm;


  List<MessageInfo>? parseMessageList(List<dynamic> messageList) {
    return messageList.map((messageInfo) {
      return MessageInfo(
          chatId: messageInfo['chatId'] ?? '',
          roomNm: messageInfo['roomNm'] ?? '',
          author: messageInfo['author'] ?? '',
          id: messageInfo['id'] ?? '',
          userImage: messageInfo['userImage'] ?? '',
          msgCode: messageInfo['msgCode'] ?? '',
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
          nextReqState: messageInfo['nextReqState'] ?? '',
          reqBtenNm: messageInfo['reqBtenNm'] ?? '',
          reqName: messageInfo['reqName'] ?? '',
          reqStepState: messageInfo['reqStepState'] ?? '',
          reqStateNm: messageInfo['reqStateNm'] ?? '',
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
      'reqStepState': reqStepState ,
      'reqStateNm': reqStateNm ,
      'userName': author,
      'msgCode': msgCode,
      'reqBtenNm': reqBtenNm,
      'nextReqState': nextReqState,
      'userImage': userImage,
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
