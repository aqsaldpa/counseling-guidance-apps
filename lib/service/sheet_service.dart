import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'package:myapp/model/user_model.dart';
import 'package:myapp/service/user_service.dart';

Map<String, dynamic> credentials = jsonDecode(dotenv.env['credentials']!);

class SheetService {
  static final gsheets = GSheets(credentials);

  static Worksheet? userSheet;
  static Worksheet? kepribadianSheet;
  static Worksheet? rekomPekerjaanSheet;
  static Worksheet? kepribadianRekomSheet;

  static Future<void> init() async {
    try {
      final spreadsheet =
          await gsheets.spreadsheet(dotenv.env['spreadsheetId']!);
      final worksheets = spreadsheet.sheets;

      for (var sheet in worksheets) {
        debugPrint("Found worksheet: ${sheet.title}");
      }

      userSheet = spreadsheet.worksheetByTitle("Pengguna");
      kepribadianSheet = spreadsheet.worksheetByTitle("Kepribadian");
      rekomPekerjaanSheet = spreadsheet.worksheetByTitle("Rekom Pekerjaan");
      kepribadianRekomSheet = spreadsheet.worksheetByTitle("Test Riasec");

      if (userSheet == null) {
        debugPrint("Warning: 'Pengguna' worksheet not found");
      }
      if (kepribadianSheet == null) {
        debugPrint("Warning: 'Kepribadian' worksheet not found");
      }
      if (rekomPekerjaanSheet == null) {
        debugPrint("Warning: 'Rekom Pekerjaan' worksheet not found");
      }
      if (kepribadianRekomSheet == null) {
        debugPrint("Warning: 'Test Riasec' worksheet not found");
      }
    } catch (e) {
      debugPrint("Error initializing sheets: $e");
    }
  }

  static Future<bool> saveUser(UserModel user) async {
    try {
      return await saveUserToSheet(user);
    } catch (e) {
      debugPrint("Error saving user data: $e");
      return false;
    }
  }

  static Future<bool> saveUserToSheet(UserModel user) async {
    try {
      if (userSheet == null) {
        debugPrint("User sheet is null. Re-initializing...");
        await init();

        if (userSheet == null) {
          debugPrint("Failed to initialize user sheet. Cannot save.");
          return false;
        }
      }

      final firstRow = await userSheet!.values.row(1);
      if (firstRow.isEmpty) {
        await userSheet!.values.insertRow(1, [
          'ID',
          'Nama',
          'Kelas',
          'Jenis Kelamin',
          'Tempat Lahir',
          'Tgl Lahir',
          'Umur',
          'Kepribadian',
        ]);
        debugPrint("Added headers to sheet");
      } else if (firstRow.length == 7) {
        await userSheet!.values.insertValue(
          'Kepribadian',
          column: 8,
          row: 1,
        );
        debugPrint("Added Kepribadian header to existing sheet");
      }

      // Generate a unique ID based on user's name and birthdate
      if (user.id.startsWith('B')) {
        // This is likely from the old generator - replace it with our new ID format
        user.id = generateUserIdFromNameAndBirthdate(user.nama, user.tglLahir);
      }

      // Check if a user with same name and birthdate already exists
      final rows = await userSheet!.values.allRows();
      bool userExists = false;

      for (int i = 1; i < rows.length; i++) {
        if (rows[i].length >= 6) {
          final rowName = rows[i][1].toString().trim().toLowerCase();
          final rowDate = rows[i][5].toString().trim();

          if (rowName == user.nama.trim().toLowerCase() &&
              normalizeDate(rowDate) == normalizeDate(user.tglLahir)) {
            debugPrint(
                "Warning: User with same name and birthdate already exists!");
            userExists = true;
            break;
          }
        }
      }

      if (userExists) {
        // If user already exists, add a timestamp to the ID to make it different
        final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
        user.id = "${user.id}$timestamp";
      }

      final values = [
        user.id,
        user.nama,
        user.kelas,
        user.jenisKelamin,
        user.tempatLahir,
        user.tglLahir,
        user.umur.toString(),
        user.kepribadian ?? '',
      ];

      debugPrint("Saving user with values: $values");

      // For new registrations, always append
      bool success = await userSheet!.values.appendRow(values);
      debugPrint("Append result: $success");

      return success;
    } catch (e) {
      debugPrint("Error saving user to sheet: $e");
      return false;
    }
  }

  static Future<UserModel?> refreshCurrentUser() async {
    try {
      final currentUser = await UserService.getCurrentUser();

      if (currentUser == null) {
        debugPrint("No user data found");
        return null;
      }

      if (userSheet == null) {
        await init();
        if (userSheet == null) {
          debugPrint("User sheet is null. Cannot refresh user data.");
          return currentUser;
        }
      }

      final rows = await userSheet!.values.allRows();
      UserModel? updatedUser;

      for (int i = 1; i < rows.length; i++) {
        if (rows[i].isNotEmpty && rows[i][0] == currentUser.id) {
          updatedUser = UserModel(
            id: rows[i][0],
            nama: rows[i][1],
            kelas: rows[i][2],
            jenisKelamin: rows[i][3],
            tempatLahir: rows[i][4],
            tglLahir: rows[i][5],
            kepribadian: rows[i].length > 7 ? rows[i][7] : null,
          );
          break;
        }
      }

      if (updatedUser != null) {
        await UserService.saveUserLocally(updatedUser);
        debugPrint("User data refreshed: ${updatedUser.toJson()}");
        return updatedUser;
      }

      return currentUser;
    } catch (e) {
      debugPrint("Error refreshing user data: $e");
      return await UserService.getCurrentUser();
    }
  }

  static Future<bool> savePersonalityType(String personalityType) async {
    try {
      final user = await UserService.getCurrentUser();
      if (user == null) {
        debugPrint("Cannot save personality type: User not found");
        return false;
      }

      user.kepribadian = personalityType;
      await UserService.saveUserLocally(user);

      // Create a dedicated method for updating just the personality
      final result = await updatePersonalityOnly(user.id, personalityType);

      debugPrint("Personality type '$personalityType' saved to sheet: $result");
      await refreshCurrentUser();

      return result;
    } catch (e) {
      debugPrint("Error saving personality type: $e");
      return false;
    }
  }

  // New method specifically for updating only the personality field
  static Future<bool> updatePersonalityOnly(
      String userId, String personalityType) async {
    try {
      if (userSheet == null) {
        await init();
        if (userSheet == null) return false;
      }

      final rows = await userSheet!.values.allRows();
      int rowIndex = -1;

      for (int i = 1; i < rows.length; i++) {
        if (rows[i].isNotEmpty && rows[i][0] == userId) {
          rowIndex = i + 1;
          break;
        }
      }

      if (rowIndex == -1) {
        debugPrint("User not found for personality update");
        return false;
      }

      // Only update the personality column (column 8)
      final success = await userSheet!.values.insertValue(
        personalityType,
        column: 8,
        row: rowIndex,
      );

      debugPrint("Personality-only update result: $success");
      return success;
    } catch (e) {
      debugPrint("Error updating personality only: $e");
      return false;
    }
  }

  static DateTime? excelDateToDateTime(String excelDateStr) {
    try {
      final double? excelDate = double.tryParse(excelDateStr.trim());
      if (excelDate != null) {
        final DateTime baseDate = DateTime(1899, 12, 30);
        return baseDate.add(Duration(days: excelDate.round()));
      }

      return null;
    } catch (e) {
      debugPrint("Error converting Excel date: $e");
      return null;
    }
  }

  static Future<bool> loginUser(String nama, String tglLahir) async {
    try {
      if (userSheet == null) {
        await init();
        if (userSheet == null) return false;
      }

      final rows = await userSheet!.values.allRows();
      debugPrint("Attempting to login with: name=$nama, birthdate=$tglLahir");

      for (int i = 1; i < rows.length; i++) {
        if (rows[i].length <= 5) {
          debugPrint("Row $i has insufficient data: ${rows[i].length} columns");
          continue;
        }

        final rowName = rows[i][1].toString().trim().toLowerCase();
        final inputName = nama.trim().toLowerCase();

        final rowDate = rows[i][5].toString().trim();
        final inputDate = tglLahir.trim();

        final nameMatches = rowName == inputName;
        if (nameMatches) {
          debugPrint("Name match found at row ${i + 1}: $rowName");
          debugPrint("Sheet date: '$rowDate', Input date: '$inputDate'");
        }

        final directDateMatch = rowDate == inputDate;
        final normalizedRowDate = normalizeDate(rowDate);
        final normalizedInputDate = normalizeDate(inputDate);
        final normalizedDateMatch = normalizedRowDate == normalizedInputDate;

        bool excelDateMatch = false;
        final excelDateTime = excelDateToDateTime(rowDate);
        if (excelDateTime != null) {
          final formattedExcelDate =
              DateFormat('dd/MM/yyyy').format(excelDateTime);
          debugPrint("Excel date converted: $rowDate -> $formattedExcelDate");

          excelDateMatch =
              normalizeDate(formattedExcelDate) == normalizedInputDate;

          if (!excelDateMatch &&
              rowDate.length == 4 &&
              int.tryParse(rowDate) != null) {
            excelDateMatch = rowDate == inputDate.split('/').last;
          }
        }

        if (nameMatches &&
            (directDateMatch || normalizedDateMatch || excelDateMatch)) {
          final user = UserModel(
            id: rows[i][0],
            nama: rows[i][1],
            kelas: rows[i][2],
            jenisKelamin: rows[i][3],
            tempatLahir: rows[i][4],
            tglLahir: rows[i][5],
            kepribadian: rows[i].length > 7 ? rows[i][7] : null,
          );

          await UserService.saveUserLocally(user);
          debugPrint("Login successful! User: ${user.toJson()}");
          debugPrint("User age calculated during login: ${user.umur}");

          return true;
        }
      }

      debugPrint("Login failed: No matching user found");
      return false;
    } catch (e) {
      debugPrint("Error during login: $e");
      return false;
    }
  }

  static String normalizeDate(String dateString) {
    return dateString
        .replaceAll("'", "")
        .replaceAll(" ", "")
        .replaceAll("-", "/")
        .trim();
  }

  static String generateUserIdFromNameAndBirthdate(
      String nama, String tglLahir) {
    // Clean up the name and birthdate
    final cleanName = nama.trim().replaceAll(' ', '').toUpperCase();
    final cleanDate = tglLahir
        .replaceAll('/', '')
        .replaceAll('-', '')
        .replaceAll("'", '')
        .trim();

    // Take the first 3 characters of the name (or all if name is shorter)
    final namePrefix =
        cleanName.length > 3 ? cleanName.substring(0, 3) : cleanName;

    // Take the last 4 digits of the cleaned date (should be the year in most cases)
    final dateComponent = cleanDate.length > 4
        ? cleanDate.substring(cleanDate.length - 4)
        : cleanDate.padLeft(4, '0');

    // Add a random component to ensure uniqueness even with same name/birthdate
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    final randomComponent = random.toString().padLeft(4, '0');

    // Combine components: NAME-DATE-RANDOM
    return '${namePrefix}${dateComponent}${randomComponent}';
  }
}
