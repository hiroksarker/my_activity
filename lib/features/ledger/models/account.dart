class Account {
  final String id;
  final String name;

  Account({required this.id, required this.name});

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
