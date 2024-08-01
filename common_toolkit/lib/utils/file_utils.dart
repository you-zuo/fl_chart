import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  ///加载缓存
  static Future<String> loadCacheSize() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      double value = await _getTotalSizeOfFilesInDir(tempDir);
      return renderSize(value);
    } catch (err) {
      print(err);
    }
    return '';
  }

  ///格式化文件大小
  static String renderSize(double value) {
    if (value.isNaN || value == 0) {
      return '0B';
    }
    List<String> unitArr = ['B', 'K', 'M', 'G'];
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  /// 递归方式 计算文件的大小
  static Future<double> _getTotalSizeOfFilesInDir(
      final FileSystemEntity file) async {
    try {
      if (file is File) {
        int length = await file.length();
        return double.parse(length.toString());
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        double total = 0;
        for (final FileSystemEntity child in children) {
          total += await _getTotalSizeOfFilesInDir(child);
        }
        return total;
      }
      return 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  ///清除缓存
  static Future<void> clearCache() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      return _deleteDir(tempDir);
    } catch (err) {
      print(err);
    }
  }

  static Future<void> _deleteDir(FileSystemEntity file) async {
    try {
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        for (final FileSystemEntity child in children) {
          await _deleteDir(child);
        }
      }
      return file.deleteSync();
    } catch (e) {
      print(e);
    }
  }
}
