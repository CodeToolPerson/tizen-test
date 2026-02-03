import 'dart:convert';
import 'dart:io';
import '../database/database.dart';

class M3UParser {
  static List<Channel> parseM3UString(String m3uContent) {
    try {
      final lines = LineSplitter.split(m3uContent).toList();
      final channels = <Channel>[];

      for (int i = 1; i < lines.length; i += 2) {
        if (i + 1 >= lines.length) break;

        final extinfLine = lines[i];
        final urlLine = lines[i + 1];

        if (extinfLine.startsWith('#EXTINF:') && !urlLine.startsWith('#')) {
          final channel = _parseChannel(extinfLine, urlLine);
          if (channel != null) {
            channels.add(channel);
          }
        }
      }

      return channels;
    } catch (e) {
      throw Exception('解析M3U字符串失败: $e');
    }
  }

  static Future<List<Channel>> parseM3UFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('M3U文件不存在: $filePath');
      }

      final lines = await file.readAsLines(encoding: utf8);
      final channels = <Channel>[];

      for (int i = 1; i < lines.length; i += 2) {
        if (i + 1 >= lines.length) break;

        final extinfLine = lines[i];
        final urlLine = lines[i + 1];

        if (extinfLine.startsWith('#EXTINF:') && !urlLine.startsWith('#')) {
          final channel = _parseChannel(extinfLine, urlLine);
          if (channel != null) {
            channels.add(channel);
          }
        }
      }

      return channels;
    } catch (e) {
      throw Exception('解析M3U文件失败: $e');
    }
  }

  static Channel? _parseChannel(String extinfLine, String urlLine) {
    try {
      final extinfMatch = RegExp(r'#EXTINF:(-?\d+)\s+(.+)').firstMatch(extinfLine);
      if (extinfMatch == null) return null;

      final attributes = _parseAttributes(extinfMatch.group(2) ?? '');
      final channelNumber = int.tryParse(attributes['channel-number'] ?? '0') ?? 0;
      final tvgId = attributes['tvg-id'] ?? '';
      final tvgName = attributes['tvg-name'] ?? '';
      final tvgLogo = attributes['tvg-logo'];
      final groupTitle = attributes['group-title'] ?? '其他';
      final definition = attributes['zz-definition'];
      final catchupSource = attributes['catchup-source'];
      final hasCatchup = attributes.containsKey('catchup') && attributes['catchup'] != 'false';
      String channelName = tvgName;
      final commaIndex = extinfLine.lastIndexOf(',');
      if (commaIndex != -1 && commaIndex < extinfLine.length - 1) {
        final nameFromEnd = extinfLine.substring(commaIndex + 1).trim();
        if (nameFromEnd.isNotEmpty) {
          channelName = nameFromEnd;
        }
      }

      return Channel()
        ..channelNumber = channelNumber
        ..tvgId = tvgId
        ..tvgName = channelName
        ..tvgLogo = tvgLogo
        ..groupTitle = groupTitle
        ..streamUrl = urlLine.trim()
        ..definition = definition
        ..catchupSource = catchupSource
        ..hasCatchup = hasCatchup;
    } catch (e) {
      print('解析频道失败: $extinfLine, 错误: $e');
      return null;
    }
  }

  static Map<String, String> _parseAttributes(String attributeString) {
    final attributes = <String, String>{};
    final regex = RegExp(r'([\w-]+)="([^"]*)"');
    final matches = regex.allMatches(attributeString);

    for (final match in matches) {
      final key = match.group(1);
      final value = match.group(2);
      if (key != null && value != null) {
        attributes[key] = value;
      }
    }

    return attributes;
  }
}
