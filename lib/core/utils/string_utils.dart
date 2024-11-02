class StringUtils {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String removeExtraSpaces(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final parts = name.split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static bool isValidUrl(String url) {
    final urlPattern = RegExp(
      r'^(http|https)://[a-zA-Z0-9-_.]+\.[a-zA-Z]{2,}[a-zA-Z0-9-_%&\?/.=]*$',
    );
    return urlPattern.hasMatch(url);
  }

  static bool containsEmoji(String text) {
    final emojiPattern = RegExp(
      r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]',
      unicode: true,
    );
    return emojiPattern.hasMatch(text);
  }
}