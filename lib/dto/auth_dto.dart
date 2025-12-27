import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

@JsonSerializable()
class RegisterDto {
  final String email;
  final String password;
  @JsonKey(name: 'username')
  final String userName;

  RegisterDto({
    required this.email,
    required this.password,
    required this.userName,
  });

  factory RegisterDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterDtoToJson(this);
}

@JsonSerializable()
class LoginDto {
  final String email;
  final String password;

  LoginDto({required this.email, required this.password});
  factory LoginDto.fromJson(Map<String, dynamic> json) =>
      _$LoginDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDtoToJson(this);
}
