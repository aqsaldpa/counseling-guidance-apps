import 'dart:convert';

class UserModel {
  String id;
  final String nama;
  final String kelas;
  final String jenisKelamin;
  final String tempatLahir;
  final String tglLahir;
  String? kepribadian;

  UserModel({
    required this.id,
    required this.nama,
    required this.kelas,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tglLahir,
    this.kepribadian,
  });

  // Get age based on birth date
  int get umur {
    final birthDate = _parseDate(formattedBirthDate);
    if (birthDate == null) return 0;

    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (_isBirthdayNotOccurredThisYear(today, birthDate)) {
      age--;
    }
    return age;
  }

  bool _isBirthdayNotOccurredThisYear(DateTime today, DateTime birthDate) {
    return today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day);
  }

  DateTime? _parseDate(String date) {
    try {
      String cleanDate = date.replaceAll("'", "");

      // Try to handle Excel date format first
      final double? excelDate = double.tryParse(cleanDate.trim());
      if (excelDate != null) {
        // Excel's epoch starts on January 0, 1900, which is actually December 31, 1899
        final DateTime baseDate = DateTime(1899, 12, 30);
        return baseDate.add(Duration(days: excelDate.round()));
      }

      // Otherwise, handle the normal dd/mm/yyyy format
      final parts = cleanDate.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
      return null;
    } catch (e) {
      print("Error parsing date: $e for date: $date");
      return null;
    }
  }

  // Get a properly formatted birth date string
  String get formattedBirthDate {
    // Try to clean up the existing date format if it's already formatted
    if (tglLahir.contains('/') || tglLahir.contains('-')) {
      return tglLahir.replaceAll("'", "").trim();
    }

    // Check if it's an Excel date serial number
    final double? excelDate =
        double.tryParse(tglLahir.replaceAll("'", "").trim());
    if (excelDate != null) {
      // Excel's epoch starts on January 0, 1900, which is actually December 31, 1899
      final DateTime baseDate = DateTime(1899, 12, 30);
      final DateTime date = baseDate.add(Duration(days: excelDate.round()));
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    // If we can't parse it as a number, return the original
    return tglLahir;
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'Nama': nama,
      'Kelas': kelas,
      'Jenis Kelamin': jenisKelamin,
      'Tempat Lahir': tempatLahir,
      'Tgl Lahir': tglLahir.replaceAll("'", ""),
      'Umur': umur.toString(),
      'Kepribadian': kepribadian,
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['ID'] ?? '',
      nama: map['Nama'] ?? '',
      kelas: map['Kelas'] ?? '',
      jenisKelamin: map['Jenis Kelamin'] ?? '',
      tempatLahir: map['Tempat Lahir'] ?? '',
      tglLahir: map['Tgl Lahir'] ?? '',
      kepribadian: map['Kepribadian'],
    );
  }

  // JSON methods
  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
