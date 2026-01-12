import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_client.dart';
import 'package:sportsy_front/dto/user_profile_dto.dart';

class UserProfileRemoteService {
  const UserProfileRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<UserProfileDto> getUserProfile(String username) async {
    try {
      final response = await _dio.get('/user/profile/$username');
      final data = response.data as Map<String, dynamic>;
      return UserProfileDto.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch user profile: ${e.response?.data}');
    }
  }

  static Future<UserProfileDto> updateProfile({
    String? username,
    String? email,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (username != null && username.isNotEmpty) body['username'] = username;
      if (email != null && email.isNotEmpty) body['email'] = email;

      final response = await _dio.patch('/user/profile', data: body);
      final data = response.data as Map<String, dynamic>;
      return UserProfileDto.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to update profile: ${e.response?.data}');
    }
  }
}
