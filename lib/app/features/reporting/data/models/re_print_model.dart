class RePrintModel {
  final String? status;
  final String? cardType;
  final Serial? serial;
  final String? ussdCode;
  final CardDetails? cardDetails;
  final CardDetails? cardDetails2;
  final String? printDate;
  final String? originalAgent;

  RePrintModel({
    this.status,
    this.cardType,
    this.serial,
    this.ussdCode,
    this.cardDetails,
    this.cardDetails2,
    this.printDate,
    this.originalAgent,
  });

  factory RePrintModel.fromJson(Map<String, dynamic> json) {
    return RePrintModel(
      status: json['status'] as String?,
      cardType: json['card_type'] as String?,
      serial: json['serial'] != null ? Serial.fromJson(json['serial']) : null,
      ussdCode: json['ussd_code'] as String?,
      cardDetails: json['card_details'] != null
          ? CardDetails.fromJson(json['card_details'])
          : null,
      cardDetails2: json['card_details2'] != null
          ? CardDetails.fromJson(json['card_details2'])
          : null,
      printDate: json['print_date'] as String?,
      originalAgent: json['original_agent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'card_type': cardType,
      'serial': serial?.toJson(),
      'ussd_code': ussdCode,
      'card_details': cardDetails?.toJson(),
      'card_details2': cardDetails2?.toJson(),
      'print_date': printDate,
      'original_agent': originalAgent,
    };
  }
}

class Serial {
  final int? id;
  final int? orderId;
  final String? serial;
  final String? code;
  final String? code1;
  final String? code2;
  final String? code3;
  final String? code4;
  final String? expiredDate;
  final int? soldPrint;
  final int? print;
  final int? rePrint;
  final String? sellDate;

  Serial({
    this.id,
    this.orderId,
    this.serial,
    this.code,
    this.code1,
    this.code2,
    this.code3,
    this.code4,
    this.expiredDate,
    this.soldPrint,
    this.print,
    this.rePrint,
    this.sellDate,
  });

  factory Serial.fromJson(Map<String, dynamic> json) {
    return Serial(
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      serial: json['serial'] as String?,
      code: json['code'] as String?,
      code1: json['code1'] as String?,
      code2: json['code2'] as String?,
      code3: json['code3'] as String?,
      code4: json['code4'] as String?,
      expiredDate: json['expired_date'] as String?,
      soldPrint: json['sold_print'] as int?,
      print: json['print'] as int?,
      rePrint: json['re_print'] as int?,
      sellDate: json['sell_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'serial': serial,
      'code': code,
      'code1': code1,
      'code2': code2,
      'code3': code3,
      'code4': code4,
      'expired_date': expiredDate,
      'sold_print': soldPrint,
      'print': print,
      're_print': rePrint,
      'sell_date': sellDate,
    };
  }
}

class CardDetails {
  final int? id;
  final int? companyId;
  final String? cardHeader;
  final String? cardFooter;
  final int? pageHeight;
  final String? photoUrl;

  CardDetails({
    this.id,
    this.companyId,
    this.cardHeader,
    this.cardFooter,
    this.pageHeight,
    this.photoUrl,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return CardDetails(
      id: json['id'] as int?,
      companyId: json['company_id'] as int?,
      cardHeader: json['card_header'] as String?,
      cardFooter: json['card_footer'] as String?,
      pageHeight: json['page_height'] as int?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'card_header': cardHeader,
      'card_footer': cardFooter,
      'page_height': pageHeight,
      'photo_url': photoUrl,
    };
  }
}
