import 'package:file_picker/file_picker.dart';

class FileHelper {
  static Future<String?> pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (result != null &&
          result.files.single.path != null) {
        return result.files.single.path!;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}