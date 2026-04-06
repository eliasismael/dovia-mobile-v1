/// Typed result for API operations.
///
/// Replaces raw [ApiCallResponse] checks scattered across widgets.
/// Usage:
/// ```dart
/// final result = await favoritesRepo.addFavorite(propertyId: id);
/// switch (result) {
///   case Success(:final data): // handle success
///   case Failure(:final message): // handle error
/// }
/// ```
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final int? statusCode;
  const Failure(this.message, {this.statusCode});
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  String? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final message) => message,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, int? statusCode) onFailure,
  }) =>
      switch (this) {
        Success(:final data) => onSuccess(data),
        Failure(:final message, :final statusCode) =>
          onFailure(message, statusCode),
      };
}
