import 'dart:io';
import 'package:image/image.dart' as img;

/**
 * [유틸] 이미지 파일 압축
 * 800 X 600 사이즈로
 */
Future<File> compressImage(File file) async {
  // 파일을 바이트로 읽기
  final bytes = await file.readAsBytes();

  // 이미지 디코딩
  img.Image? image = img.decodeImage(bytes);

  // 압축된 이미지를 파일로 저장 (사이즈 조절 없이 압축만 수행)
  final compressedFile = File(file.path);
  await compressedFile.writeAsBytes(img.encodeJpg(image!, quality: 85)); // quality: 0~100

  return compressedFile;
}
