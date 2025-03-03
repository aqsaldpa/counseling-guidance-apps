class ImageConstants {
  ImageConstants._init();
  static ImageConstants? _instace;
  static ImageConstants get instance => _instace ??= ImageConstants._init();

  String get logoApp => toPng("logo_app");
  String get registerImg => toPng("img_register");

  String toPng(String name) => "assets/$name.png";
}
