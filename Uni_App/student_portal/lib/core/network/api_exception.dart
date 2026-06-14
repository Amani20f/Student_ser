class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([this.message = 'Unauthorized access. Please login again.']);

  @override
  String toString() => 'UnauthorizedException: $message';
}
