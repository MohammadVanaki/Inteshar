class PurchaseModel {
  String? status;
  String? cardType;
  int? inventory;
  String? companyTitle;
  String? cardTitle;
  List<Serial>? serials;
  List<UssdCode>? ussdCodes;
  CardCategory? cardCategory;
  CardDetails? cardDetails;
  CardDetails? cardDetails2;
  String? printDate;
  String? originalAgent;

  PurchaseModel({
    this.status,
    this.cardType,
    this.inventory,
    this.companyTitle,
    this.cardTitle,
    this.serials,
    this.ussdCodes,
    this.cardCategory,
    this.cardDetails,
    this.cardDetails2,
    this.printDate,
    this.originalAgent,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) => PurchaseModel(
        status: json["status"],
        cardType: json["card_type"],
        inventory: json["inventory"],
        companyTitle: json["company_title"],
        cardTitle: json["card_title"],
        serials: json["serials"] == null
            ? null
            : List<Serial>.from(json["serials"].map((x) => Serial.fromJson(x))),
        ussdCodes: json["ussd_codes"] == null
            ? null
            : List<UssdCode>.from(
                json["ussd_codes"].map((x) => UssdCode.fromJson(x))),
        cardCategory: json["card_category"] == null
            ? null
            : CardCategory.fromJson(json["card_category"]),
        cardDetails: json["card_details"] == null
            ? null
            : CardDetails.fromJson(json["card_details"]),
        cardDetails2: json["card_details2"] == null
            ? null
            : CardDetails.fromJson(json["card_details2"]),
        printDate: json["print_date"],
        originalAgent: json["original_agent"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "card_type": cardType,
        "inventory": inventory,
        "company_title": companyTitle,
        "card_title": cardTitle,
        "serials": serials == null
            ? null
            : List<dynamic>.from(serials!.map((x) => x.toJson())),
        "ussd_codes": ussdCodes == null
            ? null
            : List<dynamic>.from(ussdCodes!.map((x) => x.toJson())),
        "card_category": cardCategory?.toJson(),
        "card_details": cardDetails?.toJson(),
        "card_details2": cardDetails2?.toJson(),
        "print_date": printDate,
        "original_agent": originalAgent,
      };
}

class CardCategory {
  int? id;
  String? title;
  int? price;
  String? currency;
  int? active;
  int? idShow;
  String? photoUrl;
  String? companyTitle;
  String? companyPhoto;
  int? calculatedPrice;
  Company? company;

  CardCategory({
    this.id,
    this.title,
    this.price,
    this.currency,
    this.active,
    this.idShow,
    this.photoUrl,
    this.companyTitle,
    this.companyPhoto,
    this.calculatedPrice,
    this.company,
  });

  factory CardCategory.fromJson(Map<String, dynamic> json) => CardCategory(
        id: json["id"],
        title: json["title"],
        price: json["price"],
        currency: json["currency"],
        active: json["active"],
        idShow: json["id_show"],
        photoUrl: json["photo_url"],
        companyTitle: json["company_title"],
        companyPhoto: json["company_photo"],
        calculatedPrice: json["calculated_price"],
        company:
            json["company"] == null ? null : Company.fromJson(json["company"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "currency": currency,
        "active": active,
        "id_show": idShow,
        "photo_url": photoUrl,
        "company_title": companyTitle,
        "company_photo": companyPhoto,
        "calculated_price": calculatedPrice,
        "company": company?.toJson(),
      };
}

class Company {
  int? id;
  String? title;
  String? photo;
  int? numberPrint;
  String? logoUrl;

  Company({
    this.id,
    this.title,
    this.photo,
    this.numberPrint,
    this.logoUrl,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json["id"],
        title: json["title"],
        photo: json["photo"],
        numberPrint: json["number_print"],
        logoUrl: json["logo_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "photo": photo,
        "number_print": numberPrint,
        "logo_url": logoUrl,
      };
}

class CardDetails {
  int? id;
  int? companyId;
  String? cardHeader;
  String? cardFooter;
  int? pageHeight;
  String? photoUrl;
  int? cardCategoryId;

  CardDetails({
    this.id,
    this.companyId,
    this.cardHeader,
    this.cardFooter,
    this.pageHeight,
    this.photoUrl,
    this.cardCategoryId,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) => CardDetails(
        id: json["id"],
        companyId: json["company_id"],
        cardHeader: json["card_header"],
        cardFooter: json["card_footer"],
        pageHeight: json["page_height"],
        photoUrl: json["photo_url"],
        cardCategoryId: json["card_category_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_id": companyId,
        "card_header": cardHeader,
        "card_footer": cardFooter,
        "page_height": pageHeight,
        "photo_url": photoUrl,
        "card_category_id": cardCategoryId,
      };
}

class Serial {
  int? id;
  String? serial;
  String? code;
  dynamic code1;
  dynamic code2;
  dynamic code3;
  dynamic code4;
  String? expiredDate;

  Serial({
    this.id,
    this.serial,
    this.code,
    this.code1,
    this.code2,
    this.code3,
    this.code4,
    this.expiredDate,
  });

  factory Serial.fromJson(Map<String, dynamic> json) => Serial(
        id: json["id"],
        serial: json["serial"],
        code: json["code"],
        code1: json["code1"],
        code2: json["code2"],
        code3: json["code3"],
        code4: json["code4"],
        expiredDate: json["expired_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "serial": serial,
        "code": code,
        "code1": code1,
        "code2": code2,
        "code3": code3,
        "code4": code4,
        "expired_date": expiredDate,
      };
}

class UssdCode {
  int? id;
  String? code;

  UssdCode({
    this.id,
    this.code,
  });

  factory UssdCode.fromJson(Map<String, dynamic> json) => UssdCode(
        id: json["id"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
      };
}
