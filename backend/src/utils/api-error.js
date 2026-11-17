export class ApiError extends Error {
  constructor(status, code, message, details) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.code = code;
    this.details = details;
  }

  static validation(message, details) {
    return new ApiError(400, 'VALIDATION_ERROR', message, details);
  }

  static badRequest(code, message, details) {
    return new ApiError(400, code, message, details);
  }

  static unauthorized(code, message) {
    return new ApiError(401, code, message);
  }

  static notFound(code, message) {
    return new ApiError(404, code, message);
  }

  static conflict(code, message, details) {
    return new ApiError(409, code, message, details);
  }
}
