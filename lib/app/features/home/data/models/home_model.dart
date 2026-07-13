class HomeModel {
  String? status;
  List<CompanyCategory> companyCategories;
  List<Slider> sliders;
  List<AsiacellCategory>? asiacellCategories;
  List<CardCategory>? cardCategories;
  User? user;
  int? loggedIn;

  HomeModel({
    this.status,
    required this.companyCategories,
    required this.sliders,
    this.asiacellCategories,
    this.cardCategories,
    this.user,
    this.loggedIn,
  });

  // Convert JSON to HomeModel object
  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
        status: json["status"]?.toString() ?? "",
        companyCategories: List<CompanyCategory>.from(
            json["company_categories"].map((x) => CompanyCategory.fromJson(x))),
        sliders:
            List<Slider>.from(json["sliders"].map((x) => Slider.fromJson(x))),
        asiacellCategories: json["asiacell_categories"] == null
            ? null
            : List<AsiacellCategory>.from(json["asiacell_categories"]
                .map((x) => AsiacellCategory.fromJson(x))),
        cardCategories: json["card_categories"] == null
            ? null
            : List<CardCategory>.from(
                json["card_categories"].map((x) => CardCategory.fromJson(x))),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        loggedIn: json["logged_in"],
      );

  // Convert HomeModel object to JSON
  Map<String, dynamic> toJson() => {
        "status": status,
        "company_categories":
            List<dynamic>.from(companyCategories.map((x) => x.toJson())),
        "sliders": List<dynamic>.from(sliders.map((x) => x.toJson())),
        "asiacell_categories": asiacellCategories == null
            ? null
            : List<dynamic>.from(asiacellCategories!.map((x) => x.toJson())),
        "card_categories": cardCategories == null
            ? null
            : List<dynamic>.from(cardCategories!.map((x) => x.toJson())),
        "user": user?.toJson(),
        "logged_in": loggedIn,
      };
}

class CardCategory {
  int? id;
  String? title;
  String? photo;
  String? companyTitle;
  int? companyId;
  int? price;
  int? serialCount;
  String? photoUrl;

  CardCategory({
    this.id,
    this.title,
    this.photo,
    this.companyTitle,
    this.companyId,
    this.price,
    this.serialCount,
    this.photoUrl,
  });

  // Convert JSON to CardCategory object
  factory CardCategory.fromJson(Map<String, dynamic> json) => CardCategory(
        id: json["id"],
        title: json["title"]?.toString() ?? "",
        photo: json["photo"]?.toString() ?? "",
        companyTitle: json["company_title"]?.toString() ?? "",
        companyId: json["company_id"],
        price: json["price"],
        serialCount: json["serial_count"],
        photoUrl: json["photo_url"]?.toString() ?? "",
      );

  // Convert CardCategory object to JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "photo": photo,
        "company_title": companyTitle,
        "company_id": companyId,
        "price": price,
        "serial_count": serialCount,
        "photo_url": photoUrl,
      };
}

class User {
  int? id;
  String? lang;
  String? name;
  String? officeOwner;
  String? delegate;
  int? totalBalance;
  String? username;
  String? password;
  String? codeNumber;
  int? cityId;
  int? companyId;
  int? agentId;
  String? posUsername;
  String? mobile;
  String? description;
  String? address;
  int? deviceId;
  int? active;
  int? loggedIn;
  String? firebaseToken;
  String? firebaseDevice;
  dynamic deletedAt;
  String? photoUrl;
  Agent? agent;

  User({
    this.id,
    this.lang,
    this.name,
    this.officeOwner,
    this.delegate,
    this.totalBalance,
    this.username,
    this.password,
    this.codeNumber,
    this.cityId,
    this.companyId,
    this.agentId,
    this.posUsername,
    this.mobile,
    this.description,
    this.address,
    this.deviceId,
    this.active,
    this.loggedIn,
    this.firebaseToken,
    this.firebaseDevice,
    this.deletedAt,
    this.photoUrl,
    this.agent,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        lang: json["lang"]?.toString(),
        name: json["name"]?.toString() ?? "",
        officeOwner: json["office_owner"]?.toString(),
        delegate: json["delegate"]?.toString(),
        totalBalance: json["total_balance"],
        username: json["username"]?.toString(),
        password: json["password"]?.toString(),
        codeNumber: json["code_number"]?.toString(),
        cityId: json["city_id"],
        companyId: json["company_id"],
        agentId: json["agent_id"],
        posUsername: json["pos_username"]?.toString(),
        mobile: json["mobile"]?.toString(),
        description: json["description"]?.toString(),
        address: json["address"]?.toString(),
        deviceId: json["device_id"],
        active: json["active"],
        loggedIn: json["logged_in"],
        firebaseToken: json["firebase_token"]?.toString(),
        firebaseDevice: json["firebase_device"]?.toString(),
        deletedAt: json["deleted_at"],
        photoUrl: json["photo_url"]?.toString(),
        agent: json["agent"] == null ? null : Agent.fromJson(json["agent"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lang": lang,
        "name": name,
        "office_owner": officeOwner,
        "delegate": delegate,
        "total_balance": totalBalance,
        "username": username,
        "password": password,
        "code_number": codeNumber,
        "city_id": cityId,
        "company_id": companyId,
        "agent_id": agentId,
        "pos_username": posUsername,
        "mobile": mobile,
        "description": description,
        "address": address,
        "device_id": deviceId,
        "active": active,
        "logged_in": loggedIn,
        "firebase_token": firebaseToken,
        "firebase_device": firebaseDevice,
        "deleted_at": deletedAt,
        "photo_url": photoUrl,
        "agent": agent?.toJson(),
      };
}

class Agent {
  int? id;
  int? parentId;
  String? lang;
  String? name;
  String? photo;
  String? appPhoto;
  String? email;
  int? feature;
  int? cityId;
  String? access;
  String? description;
  String? primaryColor;
  String? onPrimaryColor;
  dynamic alrabeaToken;
  int? masalBalance;
  int? numberPrint;
  int? timePrint;
  int? numberCardEdition;
  int? accessAllAgent;
  int? limitAgentPrint;
  int? active;
  dynamic deletedAt;
  String? appPhotoUrl;
  int? maxReprints;
  String? supportText;

  Agent({
    this.id,
    this.parentId,
    this.lang,
    this.name,
    this.photo,
    this.appPhoto,
    this.email,
    this.feature,
    this.cityId,
    this.access,
    this.description,
    this.primaryColor,
    this.onPrimaryColor,
    this.alrabeaToken,
    this.masalBalance,
    this.numberPrint,
    this.timePrint,
    this.numberCardEdition,
    this.accessAllAgent,
    this.limitAgentPrint,
    this.active,
    this.deletedAt,
    this.appPhotoUrl,
    this.maxReprints,
    this.supportText,
  });

  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
        id: json["id"],
        parentId: json["parent_id"],
        lang: json["lang"]?.toString(),
        name: json["name"]?.toString() ?? "",
        photo: json["photo"]?.toString(),
        appPhoto: json["app_photo"]?.toString(),
        email: json["email"]?.toString(),
        feature: json["feature"],
        cityId: json["city_id"],
        access: json["access"]?.toString(),
        description: json["description"]?.toString(),
        primaryColor: json["primary_color"]?.toString(),
        onPrimaryColor: json["on_primary_color"]?.toString(),
        alrabeaToken: json["alrabea_token"],
        masalBalance: json["masal_balance"],
        numberPrint: json["number_print"],
        timePrint: json["time_print"],
        numberCardEdition: json["number_card_edition"],
        accessAllAgent: json["access_all_agent"],
        limitAgentPrint: json["limit_agent_print"],
        active: json["active"],
        deletedAt: json["deleted_at"],
        appPhotoUrl: json["app_photo_url"]?.toString(),
        maxReprints: json["max_reprints"],
        supportText: json["support_txt"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "lang": lang,
        "name": name,
        "photo": photo,
        "app_photo": appPhoto,
        "email": email,
        "feature": feature,
        "city_id": cityId,
        "access": access,
        "description": description,
        "primary_color": primaryColor,
        "on_primary_color": onPrimaryColor,
        "alrabea_token": alrabeaToken,
        "masal_balance": masalBalance,
        "number_print": numberPrint,
        "time_print": timePrint,
        "number_card_edition": numberCardEdition,
        "access_all_agent": accessAllAgent,
        "limit_agent_print": limitAgentPrint,
        "active": active,
        "deleted_at": deletedAt,
        "app_photo_url": appPhotoUrl,
        "max_reprints": maxReprints,
        "support_txt": supportText,
      };
}

class Company {
  int? id;
  int? idShow;
  int? categoryId;
  String? title;
  int? numberPrint;
  String? logoUrl;

  Company({
    this.id,
    this.categoryId,
    this.title,
    this.idShow,
    this.numberPrint,
    this.logoUrl,
  });

  // Convert JSON to Company object
  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json["id"],
        categoryId: json["category_id"],
        title: json["title"]?.toString() ?? "",
        idShow: json["id_show"] ?? 0,
        numberPrint: json["number_print"],
        logoUrl: json["logo_url"]?.toString() ?? "",
      );

  // Convert Company object to JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "title": title,
        "id_show": idShow,
        "number_print": numberPrint,
        "logo_url": logoUrl,
      };
}

class CompanyCategory {
  int? id;
  String? title;
  int? parentId;
  List<Company> companies;

  CompanyCategory({
    this.id,
    this.title,
    this.parentId,
    required this.companies,
  });

  // Convert JSON to CompanyCategory object
  factory CompanyCategory.fromJson(Map<String, dynamic> json) {
    final list = (json["companies"] as List)
        .map((companyJson) => Company.fromJson(companyJson))
        .toList();
    // Sort by idShow (ascending)
    list.sort((a, b) => (a.idShow ?? 0).compareTo(b.idShow ?? 0));
    return CompanyCategory(
      id: json["id"],
      title: json["title"]?.toString() ?? "",
      parentId: json["parent_id"],
      companies: list,
    );
  }

  // Convert CompanyCategory object to JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "parent_id": parentId,
        "companies": companies.map((company) => company.toJson()).toList(),
      };
}

class AsiacellCategory {
  int? id;
  int? parentId;
  Type? type;
  String? title;
  int? price;
  String? img;
  String? description;
  int? show2Site;
  int? idShow;
  String? photoUrl;
  AgentPrice? agentPrice;

  AsiacellCategory({
    this.id,
    this.parentId,
    this.type,
    this.title,
    this.price,
    this.img,
    this.description,
    this.show2Site,
    this.idShow,
    this.photoUrl,
    this.agentPrice,
  });

  factory AsiacellCategory.fromJson(Map<String, dynamic> json) =>
      AsiacellCategory(
        id: json["id"],
        parentId: json["parent_id"],
        type: json["type"] == null ? null : typeValues.map[json["type"]],
        title: json["title"]?.toString() ?? "",
        price: json["price"],
        img: json["img"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
        show2Site: json["show2site"],
        idShow: json["id_show"],
        photoUrl: json["photo_url"]?.toString() ?? "",
        agentPrice: json["agent_price"] == null
            ? null
            : AgentPrice.fromJson(json["agent_price"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "type": type == null ? null : typeValues.reverse[type],
        "title": title,
        "price": price,
        "img": img,
        "description": description,
        "show2site": show2Site,
        "id_show": idShow,
        "photo_url": photoUrl,
        "agent_price": agentPrice?.toJson(),
      };
}

class AgentPrice {
  int? price;
  int? cardCategoryId;

  AgentPrice({
    this.price,
    this.cardCategoryId,
  });

  factory AgentPrice.fromJson(Map<String, dynamic> json) => AgentPrice(
        price: json["price"],
        cardCategoryId: json["card_category_id"],
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "card_category_id": cardCategoryId,
      };
}

class Slider {
  int? id;
  String? title;
  String? cityId;
  String? link;
  String? photoUrl;

  Slider({
    this.id,
    this.title,
    this.cityId,
    this.link,
    this.photoUrl,
  });

  factory Slider.fromJson(Map<String, dynamic> json) => Slider(
        id: json["id"],
        title: json["title"]?.toString() ?? "",
        cityId: json["city_id"]?.toString(),
        link: json["link"]?.toString() ?? "",
        photoUrl: json["photo_url"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "city_id": cityId,
        "link": link,
        "photo_url": photoUrl,
      };
}

enum Type { BILL, BUNDLE, TOPUP }

final typeValues =
    EnumValues({"bill": Type.BILL, "bundle": Type.BUNDLE, "topup": Type.TOPUP});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
