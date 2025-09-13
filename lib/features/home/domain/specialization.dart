class Specialization {
  final int id;
  final String name;

  const Specialization({required this.id, required this.name});

  factory Specialization.fromApi(Map<String, dynamic> json) {
    return Specialization(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}
