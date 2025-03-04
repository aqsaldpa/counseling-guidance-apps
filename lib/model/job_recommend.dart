class JobRecommendationModel {
  final String id;
  final String pekerjaan;
  final String linkGambar;
  final String deskripsi;
  final String nextStep;
  final String mapel;

  JobRecommendationModel({
    required this.id,
    required this.pekerjaan,
    this.linkGambar = "",
    this.deskripsi = "",
    this.nextStep = "",
    this.mapel = "",
  });

  @override
  String toString() {
    return 'JobRecommendationModel(id: $id, pekerjaan: $pekerjaan)';
  }
}
