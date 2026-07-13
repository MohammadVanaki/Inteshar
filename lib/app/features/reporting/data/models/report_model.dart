class ReportModel {
  String status;
  List<SerialModel> serials;

  ReportModel({
    required this.status,
    required this.serials,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      status: json['status'] ?? '',
      serials: json['serials'] != null
          ? List<SerialModel>.from(
              json['serials'].map((serial) => SerialModel.fromJson(serial)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'serials': serials.map((serial) => serial.toJson()).toList(),
    };
  }
}

class SerialModel {
  int id;
  int rePrint;
  String? serial;
  String? code;
  String? expiredDate;
  String? code1;
  String? code2;
  String? code3;
  String? code4;
  int dateTime;
  String sellType;
  String title;
  int cardId;
  String? photo;
  String companyTitle;
  String? photoUrl;
  String printDate;
  int? cardPrice;
  int? userPrice;
  int? agentPrice;
  int? parentAgentPrice;
  int? categoryPrice;

  SerialModel({
    required this.id,
    required this.rePrint,
    this.serial,
    this.code,
    this.expiredDate,
    this.code1,
    this.code2,
    this.code3,
    this.code4,
    this.cardPrice,
    required this.dateTime,
    required this.sellType,
    required this.title,
    required this.cardId,
    this.photo,
    required this.companyTitle,
    this.photoUrl,
    required this.printDate,
    this.userPrice,
    this.agentPrice,
    this.parentAgentPrice,
    this.categoryPrice,
  });

  factory SerialModel.fromJson(Map<String, dynamic> json) {
    return SerialModel(
      id: json['id'] ?? 0,
      rePrint: json['re_print'] ?? 0,
      serial: json['serial'] ?? '',
      code: json['code'] ?? '',
      expiredDate: json['expired_date'] ?? '',
      code1: json['code1'] ?? '',
      code2: json['code2'] ?? '',
      code3: json['code3'] ?? '',
      code4: json['code4'] ?? '',
      dateTime: json['date_time'] ?? 0,
      sellType: json['sell_type'] ?? '',
      title: json['title'] ?? '',
      cardId: json['card_id'] ?? 0,
      photo: json['photo'] ?? '',
      companyTitle: json['company_title'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      printDate: json['print_date'] ?? '',
      cardPrice: json['card_price'],
      userPrice: json['user_price'],
      agentPrice: json['agent_price'],
      parentAgentPrice: json['parent_agent_price'],
      categoryPrice: json['category_price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      're_print': rePrint,
      'serial': serial,
      'code': code,
      'expired_date': expiredDate,
      'code1': code1,
      'code2': code2,
      'code3': code3,
      'code4': code4,
      'date_time': dateTime,
      'sell_type': sellType,
      'title': title,
      'card_id': cardId,
      'photo': photo,
      'company_title': companyTitle,
      'photo_url': photoUrl,
      'print_date': printDate,
      'card_price': cardPrice,
      'user_price': userPrice,
      'agent_price': agentPrice,
      'parent_agent_price': parentAgentPrice,
      'category_price': categoryPrice,
    };
  }
}
