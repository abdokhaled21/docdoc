class Doctor {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String? gender;
  final String? address;
  final String? description;
  final String? degree;
  final String? specializationName;
  final String? cityName;
  final int? specializationId;
  final int? cityId;
  final String? hospitalName;
  final double? rating;
  final int? reviewsCount;
  final int? appointPrice;
  final String? startTime;
  final String? endTime;

  const Doctor({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.gender,
    this.address,
    this.description,
    this.degree,
    this.specializationName,
    this.cityName,
    this.specializationId,
    this.cityId,
    this.hospitalName,
    this.rating,
    this.reviewsCount,
    this.appointPrice,
    this.startTime,
    this.endTime,
  });

  factory Doctor.fromApi(Map<String, dynamic> json) {
    final spec = json['specialization'];
    final city = json['city'];
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return Doctor(
      id: parseInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      email: (json['email'])?.toString(),
      phone: (json['phone'])?.toString(),
      photoUrl: (json['photo'])?.toString(),
      gender: (json['gender'])?.toString(),
      address: (json['address'])?.toString(),
      description: (json['description'])?.toString(),
      degree: (json['degree'])?.toString(),
      specializationName: spec is Map<String, dynamic> ? (spec['name']?.toString()) : null,
      cityName: city is Map<String, dynamic> ? (city['name']?.toString()) : null,
      specializationId: spec is Map<String, dynamic> ? parseInt(spec['id']) : null,
      cityId: city is Map<String, dynamic> ? parseInt(city['id']) : null,
      rating: parseDouble(json['rating']),
      reviewsCount: parseInt(json['reviews_count']),
      appointPrice: parseInt(json['appoint_price']),
      startTime: (json['start_time'])?.toString(),
      endTime: (json['end_time'])?.toString(),
    );
  }
}
