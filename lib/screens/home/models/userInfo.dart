class UserInfo {
  final String id;
  final String? nickName;
  final String? profileImageUrl;
  final String? email;
  final String? clerkNo;
  final String? kakaoId;
  final String? birthday;
  final String? birthyear;
  final String? role;
  final String? name;
   String? mainAptNo;
   String? mainAptNm;
   String? mainAptPyoung;
  final List<String>? aptNo;
  final List<String>? aptName;

  UserInfo({
    required this.id,
    this.nickName,
    this.profileImageUrl,
    this.email,
    this.clerkNo,
    this.kakaoId,
    this.birthday,
    this.birthyear,
    this.role,
    this.name,
    this.mainAptNo,
    this.mainAptNm,
    this.mainAptPyoung,
    this.aptNo,
    this.aptName,
  });

  @override
  String toString() {
    return 'UserInfo{id: $id, nickName: $nickName, profileImageUrl: $profileImageUrl, email: $email, birthday: $birthday, birthyear: $birthyear}';
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      nickName: json['nickName'],
      profileImageUrl: json['profileImageUrl'],
      email: json['email'],
      clerkNo: json['clerkNo'],
      kakaoId: json['kakaoId'],
      birthday: json['birthday'],
      birthyear: json['birthyear'],
      mainAptNo: json['mainAptNo'],
      mainAptNm: json['mainAptNm'],
      mainAptPyoung: json['mainAptPyoung'],
      role: json['role'],
      name: json['name'],
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
      'kakaoId': kakaoId,
      'birthday': birthday,
      'birthyear': birthyear,
      'mainAptNo': mainAptNo,
      'mainAptNm': mainAptNm,
      'mainAptPyoung': mainAptPyoung,
      'role': role,
      'name': name,
      'aptNo': aptNo,
      'aptName': aptName,
    };
  }
}
