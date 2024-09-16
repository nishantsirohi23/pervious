class ChatUser {
  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.type,
    required this.nmessage,
    required this.nnotiwork,
    required this.nnotibooking,
    required this.mobile,
    required this.freeplatform,
    required this.points,
    required this.havepremium,
    required this.months,
    required this.totalorder,
    required this.latitude,
    required this.longitude,
    required this.superStartDate,
    required this.superEndDate,
  });

  late String image;
  late String about;
  late String name;
  late String createdAt;
  late bool isOnline;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late String type;
  late int nmessage;
  late int nnotiwork;
  late int nnotibooking;
  late String mobile;
  late int freeplatform;
  late int totalorder;
  late int points;
  late int months;
  late bool havepremium;
  late double latitude;
  late double longitude;
  late DateTime superStartDate; // Super premium start date
  late DateTime superEndDate; // Super premium end date

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    type = json['type'] ?? '';
    nmessage = json['nmessage'] ?? 0;
    nnotiwork = json['nnotiwork'] ?? 0;
    nnotibooking = json['nnotibooking'] ?? 0;
    mobile = json['mobile'] ?? '';
    freeplatform = json['freeplatform'] ?? 0;
    points = json['points'] ?? 0;
    months = json['months'] ?? 0;
    totalorder = json['totalorder'] ?? 0;
    havepremium = json['havepremium'] ?? false;
    latitude = json['latitude'] ?? 0.0;
    longitude = json['longitude'] ?? 0.0;
    superStartDate = json['superStartDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['superStartDate'].millisecondsSinceEpoch) : DateTime.now();
    superEndDate = json['superEndDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['superEndDate'].millisecondsSinceEpoch) : DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['type'] = type;
    data['nmessage'] = nmessage;
    data['nnotiwork'] = nnotiwork;
    data['nnotibooking'] = nnotibooking;
    data['mobile'] = mobile;
    data['freeplatform'] = freeplatform;
    data['points'] = points;
    data['havepremium'] = havepremium;
    data['months'] = months;
    data['totalorder'] = totalorder;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['superStartDate'] = superStartDate;
    data['superEndDate'] = superEndDate;
    return data;
  }
}
