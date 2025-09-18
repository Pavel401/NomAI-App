/// Utility class for parsing URLs, particularly Firebase Storage URLs
class UrlParser {
  /// Regex pattern to match Firebase Storage URLs
  ///
  /// This pattern matches Firebase Storage URLs in the format:
  /// https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media&token={token}
  ///
  /// Example: https://firebasestorage.googleapis.com/v0/b/mealai-f58b5.firebasestorage.app/o/chat_images%2FPavel_1758217760011.jpg?alt=media&token=38b421f0-499e-4065-911e-8f8d8e2adfb4
  static final RegExp firebaseStorageUrlPattern = RegExp(
    r'https:\/\/firebasestorage\.googleapis\.com\/v0\/b\/([^\/]+)\/o\/([^?]+)\?alt=media&token=([a-f0-9\-]+)',
    caseSensitive: false,
  );

  /// Alternative regex pattern for Firebase Storage URLs (more flexible)
  /// This pattern is more permissive and can handle variations in the URL structure
  static final RegExp firebaseStorageUrlPatternFlexible = RegExp(
    r'https:\/\/firebasestorage\.googleapis\.com\/v\d+\/b\/([^\/]+)\/o\/([^?]+)(?:\?.*)?',
    caseSensitive: false,
  );

  /// Generic URL pattern that matches most HTTP/HTTPS URLs
  static final RegExp genericUrlPattern = RegExp(
    r'https?:\/\/(?:[-\w.])+(?::[0-9]+)?(?:\/(?:[\w\/_.])*)?(?:\?(?:[\w&=%.])*)?(?:#(?:[\w.])*)?',
    caseSensitive: false,
  );

  /// Extract Firebase Storage URL from text content
  ///
  /// [content] - The text content to search for URLs
  /// Returns the first Firebase Storage URL found, or null if none found
  static String? extractFirebaseStorageUrl(String content) {
    final match = firebaseStorageUrlPattern.firstMatch(content);
    return match?.group(0);
  }

  /// Extract all Firebase Storage URLs from text content
  ///
  /// [content] - The text content to search for URLs
  /// Returns a list of all Firebase Storage URLs found
  static List<String> extractAllFirebaseStorageUrls(String content) {
    final matches = firebaseStorageUrlPattern.allMatches(content);
    return matches.map((match) => match.group(0)!).toList();
  }

  /// Extract any URL from text content using a more flexible pattern
  ///
  /// [content] - The text content to search for URLs
  /// Returns the first URL found, or null if none found
  static String? extractAnyUrl(String content) {
    final match = genericUrlPattern.firstMatch(content);
    return match?.group(0);
  }

  /// Extract all URLs from text content
  ///
  /// [content] - The text content to search for URLs
  /// Returns a list of all URLs found
  static List<String> extractAllUrls(String content) {
    final matches = genericUrlPattern.allMatches(content);
    return matches.map((match) => match.group(0)!).toList();
  }

  /// Parse Firebase Storage URL components
  ///
  /// [url] - The Firebase Storage URL to parse
  /// Returns a map with 'bucket', 'path', and 'token' keys, or null if not a valid Firebase Storage URL
  static Map<String, String>? parseFirebaseStorageUrl(String url) {
    final match = firebaseStorageUrlPattern.firstMatch(url);
    if (match == null) return null;

    return {
      'bucket': match.group(1) ?? '',
      'path': Uri.decodeComponent(match.group(2) ?? ''),
      'token': match.group(3) ?? '',
      'fullUrl': match.group(0) ?? '',
    };
  }

  /// Check if a string contains a Firebase Storage URL
  ///
  /// [content] - The text content to check
  /// Returns true if the content contains at least one Firebase Storage URL
  static bool containsFirebaseStorageUrl(String content) {
    return firebaseStorageUrlPattern.hasMatch(content);
  }

  /// Check if a string is a valid Firebase Storage URL
  ///
  /// [url] - The URL string to validate
  /// Returns true if the URL is a valid Firebase Storage URL
  static bool isFirebaseStorageUrl(String url) {
    return firebaseStorageUrlPattern.hasMatch(url);
  }

  /// Validate if a URL is accessible (basic format validation)
  ///
  /// [url] - The URL to validate
  /// Returns true if the URL has a valid format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Remove "User provided an image" text patterns from content
  ///
  /// This method removes various patterns like:
  /// - [User provided an image: URL]
  /// - User provided an image: URL
  /// - (User provided an image: URL)
  /// And returns the cleaned content
  ///
  /// [content] - The text content to clean
  /// Returns the content with user provided image references removed
  static String removeUserProvidedImageText(String content) {
    // Pattern to match various formats of "User provided an image" text
    final patterns = [
      // Match [User provided an image: URL] (most common format)
      RegExp(r'\[User provided an image:\s*[^\]]+\]', caseSensitive: false),

      // Match (User provided an image: URL)
      RegExp(r'\(User provided an image:\s*[^)]+\)', caseSensitive: false),

      // Match User provided an image: URL (without brackets)
      RegExp(r'User provided an image:\s*\S+', caseSensitive: false),

      // Match any variation with "user", "provided", "image" and a URL
      RegExp(r'\[?User\s+provided\s+an?\s+image[:\s]*[^\])\s]*\]?',
          caseSensitive: false),
    ];

    String cleanedContent = content;

    // Apply each pattern to remove the text
    for (final pattern in patterns) {
      cleanedContent = cleanedContent.replaceAll(pattern, '');
    }

    // Clean up extra whitespace and line breaks
    cleanedContent = cleanedContent
        .replaceAll(
            RegExp(r'\n\s*\n\s*\n'), '\n\n') // Remove triple+ line breaks
        .replaceAll(RegExp(r'^\s+'), '') // Remove leading whitespace
        .replaceAll(RegExp(r'\s+$'), '') // Remove trailing whitespace
        .trim();

    return cleanedContent;
  }

  /// Extract Firebase Storage URL and remove user provided image text in one operation
  ///
  /// [content] - The text content to process
  /// Returns a map with 'url' (extracted Firebase Storage URL) and 'cleanedContent' (content without user provided image text)
  static Map<String, String?> extractUrlAndCleanContent(String content) {
    final extractedUrl = extractFirebaseStorageUrl(content);
    final cleanedContent = removeUserProvidedImageText(content);

    return {
      'url': extractedUrl,
      'cleanedContent': cleanedContent,
    };
  }
}
