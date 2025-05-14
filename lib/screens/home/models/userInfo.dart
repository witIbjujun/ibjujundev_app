class UserInfo {
  final String? id;
  final String? nickName;
  final String? profileImageUrl;
  final String? email;
  final String? clerkNo;
  final String? kakaoId;
  final String? birthday;
  final String? birthyear;
  final String? loginSnsType;
  final String? role;
  String? tempClerkNo;
  String? mainAptNo;
  String? mainAptNm;
  String? mainAptPyoung;
  final List<String>? aptNo;
  final List<String>? aptName;

  UserInfo({
    this.id,
    this.nickName,
    this.profileImageUrl,
    this.email,
    this.clerkNo,
    this.tempClerkNo,
    this.loginSnsType,
    this.kakaoId,
    this.birthday,
    this.birthyear,
    this.role,
    this.mainAptNo,
    this.mainAptNm,
    this.mainAptPyoung,
    this.aptNo,
    this.aptName,
  });

  @override
  String toString() {
    return 'UserInfo{id: $id, nickName: $nickName, profileImageUrl: $profileImageUrl,loginSnsType: $loginSnsType, email: $email, birthday: $birthday, birthyear: $birthyear}';
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      nickName: json['nickName'],
      profileImageUrl: json['profileImageUrl'],
      email: json['email'],
      clerkNo: json['clerkNo'],
      tempClerkNo: json['tempClerkNo'],
      kakaoId: json['kakaoId'],
      loginSnsType: json['loginSnsType'],
      birthday: json['birthday'],
      birthyear: json['birthyear'],
      mainAptNo: json['mainAptNo'],
      mainAptNm: json['mainAptNm'],
      mainAptPyoung: json['mainAptPyoung'],
      role: json['role'],
      aptNo: json['aptNo'] != null ? List<String>.from(json['aptNo']) : null,
      aptName: json['aptName'] != null ? List<String>.from(json['aptName']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickName': nickName,
      'profileImageUrl': profileImageUrl,
      'email': email,
      'clerkNo': clerkNo,
      'tempClerkNo': tempClerkNo,
      'kakaoId': kakaoId,
      'loginSnsType': loginSnsType,
      'birthday': birthday,
      'birthyear': birthyear,
      'mainAptNo': mainAptNo,
      'mainAptNm': mainAptNm,
      'mainAptPyoung': mainAptPyoung,
      'role': role,
      'aptNo': aptNo,
      'aptName': aptName,
    };
  }
}
