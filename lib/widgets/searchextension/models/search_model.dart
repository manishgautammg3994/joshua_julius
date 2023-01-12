class Searchmodel {
  Searchmodel({
    required this.id,
    required this.name,
    required this.file,
    required this.categoryId,
    required this.subcategoryId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Searchmodel.fromJson(Map<dynamic, dynamic> json) => Searchmodel(
      id: json['id'],
      name: json['name'],
      file: json['file'],
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      userId: json['user_id'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at']);
  //

  //
  int? id;
  String? name;
  String? file;
  int? categoryId;
  int? subcategoryId;
  String? userId;
  String? status;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['file'] = file;
    map['category_id'] = categoryId;
    map['subcategory_id'] = subcategoryId;
    map['user_id'] = userId;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
