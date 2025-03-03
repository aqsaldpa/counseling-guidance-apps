import 'package:flutter/material.dart';
import 'package:myapp/model/personality_model.dart';
import 'package:myapp/service/sheet_service.dart';

class PersonalityService {
  static Future<PersonalityModel?> getPersonalityByCategory(
      String category) async {
    try {
      debugPrint("Searching for personality data for category: '$category'");

      if (SheetService.kepribadianSheet == null) {
        await SheetService.init();
        if (SheetService.kepribadianSheet == null) {
          debugPrint("Kepribadian sheet is null. Cannot get personality data.");
          return null;
        }
      }

      final rows = await SheetService.kepribadianSheet!.values.allRows();

      debugPrint("Found ${rows.length} rows in kepribadianSheet");
      if (rows.isNotEmpty) {
        debugPrint("Headers in kepribadianSheet: ${rows[0]}");
      }

      int categoryColIndex = -1;
      int strengthColIndex = -1;
      int weaknessColIndex = -1;
      int characteristicColIndex = -1;
      int deskripsiColIndex = -1;

      if (rows.isNotEmpty) {
        for (int i = 0; i < rows[0].length; i++) {
          String header = rows[0][i].toString().toLowerCase();
          if (header.contains("kategori")) {
            categoryColIndex = i;
          } else if (header.contains("strength")) {
            strengthColIndex = i;
          } else if (header.contains("weakness")) {
            weaknessColIndex = i;
          } else if (header.contains("characteristic")) {
            characteristicColIndex = i;
          } else if (header.contains("deskripsi")) {
            deskripsiColIndex = i;
          }
        }

        debugPrint(
            "Category column: $categoryColIndex, Strength: $strengthColIndex, Weakness: $weaknessColIndex, Characteristic: $characteristicColIndex");
      }

      if (categoryColIndex == -1) categoryColIndex = 1;
      if (strengthColIndex == -1) strengthColIndex = 3;
      if (weaknessColIndex == -1) weaknessColIndex = 4;
      if (characteristicColIndex == -1) characteristicColIndex = 5;
      if (deskripsiColIndex == -1) deskripsiColIndex = 6;

      for (int i = 1; i < rows.length; i++) {
        if (rows[i].isNotEmpty && rows[i].length > categoryColIndex) {
          String rowCategory = rows[i][categoryColIndex].toString().trim();
          debugPrint("Row $i: comparing '$rowCategory' with '$category'");

          if (rowCategory.toLowerCase() == category.toLowerCase()) {
            debugPrint("Found matching personality category");

            List<String> strengths = [];
            if (rows[i].length > strengthColIndex &&
                rows[i][strengthColIndex].isNotEmpty) {
              strengths = rows[i][strengthColIndex]
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            }

            List<String> weaknesses = [];
            if (rows[i].length > weaknessColIndex &&
                rows[i][weaknessColIndex].isNotEmpty) {
              weaknesses = rows[i][weaknessColIndex]
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            }

            List<String> characteristic = [];
            if (rows[i].length > characteristicColIndex &&
                rows[i][characteristicColIndex].isNotEmpty) {
              characteristic = rows[i][characteristicColIndex]
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            }

            return PersonalityModel(
              id: rows[i][0],
              kategori: rowCategory,
              strengths: strengths,
              weaknesses: weaknesses,
              characteristic: characteristic,
              deskripsi: rows[i].length > deskripsiColIndex
                  ? rows[i][deskripsiColIndex]
                  : "",
            );
          }
        }
      }

      debugPrint("No matching personality found for category: $category");
      return null;
    } catch (e) {
      debugPrint("Error getting personality data: $e");
      return null;
    }
  }
}
