class Dosen {
  final int id;
  final String nama;
  final String username;
  final String email;
  final String telepon;
  final String website;
  final String instansi;

  Dosen({
    required this.id,
    required this.nama,
    required this.username,
    required this.email,
    required this.telepon,
    required this.website,
    required this.instansi,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    return Dosen(
      id: json['id'] as int,
      nama: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      telepon: json['phone'] as String,
      website: json['website'] as String,
      instansi: (json['company'] as Map<String, dynamic>)['name'] as String,
    );
  }
}
