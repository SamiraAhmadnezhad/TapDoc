class Doc{
  String? id;
  String title;
  String? description;
  Map<String , dynamic>? extra;

  Doc({
    this.id,
    required this.title ,
    this.description,
    this.extra
  });

}