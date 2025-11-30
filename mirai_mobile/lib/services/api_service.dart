import 'package:dio/dio.dart';
import 'package:mirai_mobile/models/auth_response_model.dart';
import 'package:mirai_mobile/models/booking_model.dart';
import 'package:mirai_mobile/models/ticket_type_model.dart';
import 'package:mirai_mobile/models/user_model.dart';
import 'package:mirai_mobile/services/storage_service.dart';
import 'package:mirai_mobile/utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final _storage = StorageService();

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for automatic token injection
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle errors globally
          print('DioError: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Authentication Endpoints

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Ticket Endpoints

  Future<List<TicketTypeModel>> getTickets() async {
    try {
      final response = await _dio.get('/tickets');

      if (response.data['success'] == true) {
        final List ticketsData = response.data['data'] ?? [];
        return ticketsData
            .map((json) => TicketTypeModel.fromJson(json))
            .toList();
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch tickets');
    } catch (e) {
      rethrow;
    }
  }

  Future<TicketTypeModel> getTicketDetail(int id) async {
    try {
      final response = await _dio.get('/tickets/$id');

      if (response.data['success'] == true) {
        return TicketTypeModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch ticket');
    } catch (e) {
      rethrow;
    }
  }

  // Booking Endpoints

  Future<Map<String, dynamic>> createBooking({
    required int ticketTypeId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post(
        '/bookings',
        data: {'ticket_type_id': ticketTypeId, 'quantity': quantity},
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BookingModel>> getBookings() async {
    try {
      final response = await _dio.get('/bookings');

      if (response.data['success'] == true) {
        final List bookingsData = response.data['data'] ?? [];
        return bookingsData.map((json) => BookingModel.fromJson(json)).toList();
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch bookings');
    } catch (e) {
      rethrow;
    }
  }

  Future<BookingModel> getBookingDetail(int id) async {
    try {
      final response = await _dio.get('/bookings/$id');

      if (response.data['success'] == true) {
        return BookingModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch booking');
    } catch (e) {
      rethrow;
    }
  }

  // User Endpoints

  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dio.get('/user/profile');

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to fetch profile');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateUserProfile({String? name, String? phone}) async {
    try {
      final response = await _dio.post(
        '/user/profile',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to update profile');
    } catch (e) {
      rethrow;
    }
  }
}
