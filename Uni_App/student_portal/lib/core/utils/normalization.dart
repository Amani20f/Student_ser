String normalizePhone(String input) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  
  String normalized = input;
  for (int i = 0; i < 10; i++) {
    normalized = normalized.replaceAll(arabicDigits[i], englishDigits[i]);
  }
  
  // Keep only digits (and optional leading plus sign)
  normalized = normalized.replaceAll(RegExp(r'[^\d+]'), '');
  
  // Enforce max length of 15 digits (excluding plus sign if present)
  final onlyDigits = normalized.replaceAll(RegExp(r'\D'), '');
  if (onlyDigits.length > 15) {
    final plusPrefix = normalized.startsWith('+') ? '+' : '';
    normalized = plusPrefix + onlyDigits.substring(0, 15);
  }
  
  return normalized;
}

bool isValidPhoneNumber(String normalizedInput) {
  final cleanDigits = normalizedInput.replaceAll(RegExp(r'\D'), '');
  return cleanDigits.length >= 8 && cleanDigits.length <= 15;
}

/// Normalizes a file URL returned by the backend (e.g. http://localhost:8000/...)
/// to use the same host as the API base URL (e.g. http://10.0.2.2:8000/...).
/// This fixes image/file loading on Android emulators.
String normalizeFileUrl(String url) {
  if (url.isEmpty) return url;
  const baseUrl = 'http://10.0.2.2:8000';
  String normalized = url;
  
  if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
    if (normalized.startsWith('/')) {
      normalized = '$baseUrl$normalized';
    } else {
      normalized = '$baseUrl/$normalized';
    }
  } else {
    normalized = normalized.replaceFirst('http://localhost:8000', baseUrl);
    normalized = normalized.replaceFirst('http://127.0.0.1:8000', baseUrl);
  }
  return normalized;
}
