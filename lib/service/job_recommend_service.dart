import 'package:flutter/material.dart';
import 'package:myapp/model/job_recommend.dart';
import 'package:myapp/service/sheet_service.dart';

class JobRecommendationService {
  static Future<List<JobRecommendationModel>> getJobsByPersonality(
      String personalityType) async {
    List<JobRecommendationModel> recommendations = [];
    try {
      debugPrint(
          "Searching for recommendations for personality type: '$personalityType'");
      if (SheetService.rekomPekerjaanSheet == null ||
          SheetService.kepribadianSheet == null) {
        await SheetService.init();
      }

      final rekomRows = await SheetService.kepribadianSheet!.values.allRows();
      debugPrint("Found ${rekomRows.length} rows in kepribadianSheet");
      if (rekomRows.isNotEmpty) {
        debugPrint("Headers in kepribadianSheet: ${rekomRows[0]}");
      }

      int personalityColIndex = -1;
      int jobRecomColIndex = -1;

      // Find the column indices
      if (rekomRows.isNotEmpty) {
        for (int i = 0; i < rekomRows[0].length; i++) {
          String header = rekomRows[0][i].toString().toLowerCase();
          if (header.contains("kategori") ||
              header.contains("kepribadian") ||
              header.contains("personality")) {
            personalityColIndex = i;
          } else if (header.contains("rekom") ||
              header.contains("pekerjaan") ||
              header.contains("job")) {
            jobRecomColIndex = i;
          }
        }
        debugPrint(
            "Personality column index: $personalityColIndex, Job recommendation column index: $jobRecomColIndex");
      }

      if (personalityColIndex == -1) personalityColIndex = 1;
      if (jobRecomColIndex == -1) jobRecomColIndex = 2;

      // Collect all matching jobs
      List<String> matchingJobs = [];
      for (int i = 1; i < rekomRows.length; i++) {
        if (rekomRows[i].isNotEmpty &&
            rekomRows[i].length > personalityColIndex) {
          String rowPersonality =
              rekomRows[i][personalityColIndex].toString().trim();

          debugPrint(
              "Row $i: comparing '$rowPersonality' with '$personalityType'");

          if (rowPersonality.toLowerCase() == personalityType.toLowerCase()) {
            // Check if there's a job recommendation
            if (rekomRows[i].length > jobRecomColIndex &&
                rekomRows[i][jobRecomColIndex].toString().isNotEmpty) {
              // Handle multiple jobs in one cell (comma or space separated)
              String jobsInCell =
                  rekomRows[i][jobRecomColIndex].toString().trim();

              // Check if we have multiple jobs separated by commas
              if (jobsInCell.contains(',')) {
                List<String> jobList = jobsInCell
                    .split(',')
                    .map((job) => job.trim())
                    .where((job) => job.isNotEmpty)
                    .toList();
                matchingJobs.addAll(jobList);
                debugPrint("Added multiple comma-separated jobs: $jobList");
              }
              // Check for space-separated jobs (like "Kriya Kayu")
              else {
                matchingJobs.add(jobsInCell);
                debugPrint("Added job: $jobsInCell");
              }
            }
          }
        }
      }

      debugPrint("Found ${matchingJobs.length} matching jobs: $matchingJobs");

      // Get job details
      final jobDetailsRows =
          await SheetService.rekomPekerjaanSheet!.values.allRows();

      // Get column index for mata pelajaran
      int mapelColIndex = -1;
      if (jobDetailsRows.isNotEmpty) {
        for (int i = 0; i < jobDetailsRows[0].length; i++) {
          String header = jobDetailsRows[0][i].toString().toLowerCase();
          if (header.contains("mapel") ||
              header.contains("mata pelajaran") ||
              header.contains("subject")) {
            mapelColIndex = i;
            break;
          }
        }
        // Jika tidak ditemukan header yang cocok, coba gunakan kolom 5 (sesuai gambar)
        if (mapelColIndex == -1 && jobDetailsRows[0].length > 5) {
          mapelColIndex = 5;
        }
        debugPrint("Mata pelajaran column index: $mapelColIndex");
      }

      for (int i = 1; i < jobDetailsRows.length; i++) {
        if (jobDetailsRows[i].isNotEmpty && jobDetailsRows[i].length > 1) {
          String jobName = jobDetailsRows[i][1].trim();
          debugPrint("Checking if '$jobName' is in our matching jobs list");

          // Check for exact match or if this job name is contained in any of our matching jobs
          if (matchingJobs.contains(jobName) ||
              matchingJobs.any((job) =>
                  job.toLowerCase() == jobName.toLowerCase() ||
                  job.toLowerCase().contains(jobName.toLowerCase()) ||
                  jobName.toLowerCase().contains(job.toLowerCase()))) {
            debugPrint("Found matching job detail: $jobName");

            // Get mapel data if available
            String mapelData = "";
            if (mapelColIndex != -1 &&
                jobDetailsRows[i].length > mapelColIndex &&
                jobDetailsRows[i][mapelColIndex].toString().isNotEmpty) {
              mapelData = jobDetailsRows[i][mapelColIndex].toString().trim();
              debugPrint("Mata pelajaran for $jobName: $mapelData");
            }

            recommendations.add(JobRecommendationModel(
              id: jobDetailsRows[i][0],
              pekerjaan: jobName,
              linkGambar:
                  jobDetailsRows[i].length > 2 ? jobDetailsRows[i][2] : "",
              deskripsi:
                  jobDetailsRows[i].length > 3 ? jobDetailsRows[i][3] : "",
              nextStep:
                  jobDetailsRows[i].length > 4 ? jobDetailsRows[i][4] : "",
              mapel: mapelData,
            ));
          }
        }
      }

      debugPrint("Returning ${recommendations.length} job recommendations");
      return recommendations;
    } catch (e) {
      debugPrint("Error getting job recommendations: $e");
      return recommendations;
    }
  }
}
