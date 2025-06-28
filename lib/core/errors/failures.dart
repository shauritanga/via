import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {
  final String message;
  
  const ServerFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  final String message;
  
  const CacheFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  final String message;
  
  const NetworkFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

// Voice-specific failures
class SpeechRecognitionFailure extends Failure {
  final String message;
  
  const SpeechRecognitionFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class TextToSpeechFailure extends Failure {
  final String message;
  
  const TextToSpeechFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

// Document-specific failures
class DocumentNotFoundFailure extends Failure {
  final String message;
  
  const DocumentNotFoundFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class DocumentParsingFailure extends Failure {
  final String message;
  
  const DocumentParsingFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class PermissionFailure extends Failure {
  final String message;
  
  const PermissionFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class AuthenticationFailure extends Failure {
  final String message;
  
  const AuthenticationFailure(this.message);
  
  @override
  List<Object> get props => [message];
}
