import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';
import 'package:doctro/retrofit/apis.dart';
import 'package:http_parser/http_parser.dart';
import 'astra_gateway_auth.dart';

/// Legacy Astra Service - Maintained for backward compatibility
///
/// For new implementations, use [AstraApiService] from astra_api_service.dart
/// which provides access to all Astra AI Healthcare endpoints.
class AstraService {
  static final AstraService _instance = AstraService._internal();
  late Dio _dio;

  /// Use the actual backend URL here.
  final String baseUrl = Apis.astraBaseUrl;

  factory AstraService() {
    return _instance;
  }

  AstraService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 45),
      receiveTimeout: Duration(seconds: 90),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // The real backend issues its own short-lived JWT in exchange for a
        // Firebase ID token and rejects a raw Firebase token outright - see
        // AstraGatewayAuth for the exchange/cache logic this mirrors.
        try {
          final astraToken = await _gatewayAuth.getAccessToken();
          options.headers['Authorization'] = 'Bearer $astraToken';
        } catch (_) {
          // No Firebase session to exchange.
        }
        if (options.headers['Content-Type'] == null) {
          options.headers['Content-Type'] = 'application/json';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('AstraService error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  final AstraGatewayAuth _gatewayAuth = AstraGatewayAuth();

  // ============================================================
  // DOCTOR ENDPOINTS
  // ============================================================

  /// Register a new doctor
  Future<Response> registerDoctor(Map<String, dynamic> data) async {
    try {
      return await _dio.post('/api/v1/api/doctors/register', data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get doctor profile
  Future<Response> getDoctorProfile(String doctorId) async {
    try {
      return await _dio.get('/api/v1/api/doctors/$doctorId');
    } catch (e) {
      rethrow;
    }
  }

  /// Update doctor profile
  Future<Response> updateDoctorProfile(
      String doctorId, Map<String, dynamic> data) async {
    try {
      return await _dio.put('/api/v1/api/doctors/$doctorId', data: data);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // PATIENT ENDPOINTS
  // ============================================================

  /// Get comprehensive patient view (profile + AI intake + history)
  Future<Map<String, dynamic>> getPatientView(String patientId) async {
    try {
      final response = await _dio.get('/api/v1/patients/profile/$patientId');
      return response.data;
    } catch (e) {
      return {
        "patient_profile": {},
        "latest_astra_fill": {},
        "recent_consultations": [],
        "prescription_history": []
      };
    }
  }

  /// Get Astra Fill records (health intake) submitted by patient
  /// Returns the symptoms, medical history, and vitals that patient entered
  Future<Map<String, dynamic>> getAstraFillRecords(String patientId) async {
    try {
      final response =
          await _dio.get('/api/v1/astra-fill/patient/$patientId/records');
      if (response.data is List) {
        if ((response.data as List).isNotEmpty) {
          return response.data[0] as Map<String, dynamic>;
        }
        return {};
      }
      return response.data ?? {};
    } catch (e) {
      return {};
    }
  }

  /// Get latest Astra Fill (most recent health intake from patient)
  Future<Map<String, dynamic>> getLatestAstraFill(String patientId) async {
    try {
      final response =
          await _dio.get('/api/v1/astra-fill/patient/$patientId/latest');
      if (response.data is List) {
        if ((response.data as List).isNotEmpty) {
          return response.data[0] as Map<String, dynamic>;
        }
        return {};
      }
      return response.data ?? {};
    } catch (e) {
      return {};
    }
  }

  /// Get all Astra Fill history for a patient
  Future<List<dynamic>> getAstraFillHistory(String patientId) async {
    try {
      final response =
          await _dio.get('/api/v1/astra-fill/patient/$patientId/history');
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Get patient consultation data including Astra Fill (for doctor view)
  Future<Map<String, dynamic>> getPatientConsultationData(
      String patientId) async {
    try {
      // Fetch multiple data sources in parallel
      final futures = await Future.wait([
        _dio.get('/api/v1/patients/profile/$patientId'),
        _dio
            .get('/api/v1/astra-fill/patient/$patientId/latest')
            .catchError((_) => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: {},
                )),
        _dio
            .get('/api/v1/api/prescriptions/patient/$patientId')
            .catchError((_) => Response(
                  requestOptions: RequestOptions(path: ''),
                  data: [],
                )),
      ]);

      return {
        "patient_profile": futures[0].data ?? {},
        "latest_astra_fill": futures[1].data ?? {},
        "prescription_history": futures[2].data ?? [],
      };
    } catch (e) {
      return {
        "patient_profile": {},
        "latest_astra_fill": {},
        "prescription_history": []
      };
    }
  }

  /// Search patients by name, phone, or code
  Future<List<dynamic>> searchPatients(String searchTerm) async {
    try {
      final response = await _dio.get('/api/v1/patients/search/$searchTerm');
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Register a new patient
  Future<Response> registerPatient(Map<String, dynamic> data) async {
    try {
      return await _dio.post('/api/v1/patients/register', data: data);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // PRESCRIPTION & MEDICINE ENDPOINTS
  // ============================================================

  /// Search medicines from Shopify inventory
  Future<List<dynamic>> searchMedicines(String query) async {
    try {
      final response = await _dio.get('/api/v1/shopify/products/search/$query');
      if (response.data is List) return response.data;
      if (response.data is Map) {
        return response.data['products'] ?? response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get available medicines
  Future<List<dynamic>> getAvailableMedicines() async {
    try {
      final response = await _dio.get('/api/v1/shopify/products/available');
      if (response.data is List) return response.data;
      if (response.data is Map) {
        return response.data['products'] ?? response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Suggest medicines based on symptoms
  Future<List<dynamic>> suggestMedicinesFromSymptoms(
      List<String> symptoms) async {
    try {
      final response = await _dio
          .post('/api/v1/shopify/ai-shop-assist', data: {'symptoms': symptoms});
      return response.data?['recommendations'] ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Create prescription
  Future<Response> createPrescription(Map<String, dynamic> data) async {
    try {
      return await _dio.post('/api/v1/api/prescriptions/create', data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get patient prescriptions
  Future<List<dynamic>> getPatientPrescriptions(String patientId) async {
    try {
      final response =
          await _dio.get('/api/v1/api/prescriptions/patient/$patientId');
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // AI / ASTRA BRAIN ENDPOINTS
  // ============================================================

  /// Chat with Astra AI Brain - raw AI chat streaming with no journey
  /// context or safety wrapper, which is exactly right for a doctor's
  /// free-form AI assist query. Two other live chat routes exist on this
  /// same backend and are deliberately NOT used here - they are different
  /// services, not duplicates, so don't "fix" this by switching to one of
  /// them:
  ///   - `/api/companion/chat` - the journey-scoped patient companion
  ///     chat (safety middleware, intent-decay monitoring); this is what
  ///     the patient app uses instead, for a genuinely different purpose.
  ///   - `/api/v1/chat/message` - a separate, non-journey-scoped pipeline
  ///     (Supabase session validation, RAG memory, language detection).
  Future<Map<String, dynamic>> chatWithAstra(String message, String userId,
      {Map<String, dynamic>? metadata}) async {
    try {
      final response = await _dio.post('/api/v1/brain/chat', data: {
        'q': message,
        'user_id': userId,
        'user_metadata': metadata ?? {'role': 'doctor'},
      });
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Generate doctor summary from patient data
  Future<Map<String, dynamic>> generateDoctorSummary(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/api/v1/brain/doctor_summary', data: data);
      return response.data;
    } catch (e) {
      return {};
    }
  }

  /// Analyze medication safety
  Future<Map<String, dynamic>> analyzeMedicationSafety(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/api/v1/brain/analyze_safety', data: data);
      return response.data;
    } catch (e) {
      return {'is_safe': true, 'warnings': []};
    }
  }

  /// Extract medication schedule from text
  Future<Map<String, dynamic>> extractSchedule(String text) async {
    try {
      final response = await _dio
          .post('/api/v1/brain/extract_schedule', data: {'text': text});
      return response.data;
    } catch (e) {
      return {};
    }
  }

  // ============================================================
  // ASTRA FILL (Voice Processing)
  // ============================================================

  /// Process voice for prescription extraction
  Future<Map<String, dynamic>> processVoice(File audioFile, String userId,
      {String languageCode = "en-IN"}) async {
    try {
      String fileName = p.basename(audioFile.path);
      FormData formData = FormData.fromMap({
        "audio": await MultipartFile.fromFile(
          audioFile.path,
          filename: fileName,
          contentType: MediaType('audio', 'wav'),
        ),
        "user_id": userId,
        "language_code": languageCode,
      });

      final response = await _dio.post(
        '/api/v1/astra-fill/process-voice',
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Process text for data extraction
  Future<Map<String, dynamic>> processText(Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/api/v1/astra-fill/process-text', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm extraction
  Future<Map<String, dynamic>> confirmExtraction(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/api/v1/astra-fill/confirm', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // CONSULTATION ENDPOINTS
  // ============================================================

  /// Create consultation record.
  ///
  /// `/api/v1/patients/consultation` does not exist on the real backend
  /// (confirmed against the live OpenAPI spec at astra.ayureze.in/openapi.json
  /// - there is no route for "save consultation notes" at all, only
  /// appointment booking/cancel and admin-crm consultation records). Not
  /// called from anywhere in this app, so this has never actually run; left
  /// here as a documented gap rather than guessing a replacement target.
  Future<Response> createConsultation(Map<String, dynamic> data) async {
    try {
      return await _dio.post('/api/v1/patients/consultation', data: data);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // DOCUMENT ENDPOINTS
  // ============================================================

  /// Upload document
  Future<Map<String, dynamic>> uploadDocument(
      File file, String patientId, String documentType) async {
    try {
      String fileName = p.basename(file.path);
      String ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
      String mimeType = ext == 'pdf' ? 'application/pdf' : 'image/$ext';

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
        "patient_id": patientId,
        "document_type": documentType,
      });

      final response = await _dio.post(
        '/api/v1/documents/upload',
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// List patient documents
  Future<List<dynamic>> listPatientDocuments(String patientId) async {
    try {
      final response = await _dio.get('/api/v1/documents/patient/$patientId');
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Share document via WhatsApp
  Future<Map<String, dynamic>> shareDocumentViaWhatsApp(
      String documentId) async {
    try {
      final response =
          await _dio.post('/api/v1/documents/share-whatsapp/$documentId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // CATCHY PRESCRIPTIONS
  // ============================================================

  /// Generate catchy prescription from data
  Future<Map<String, dynamic>> generateCatchyPrescription(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/api/v1/prescriptions/catchy-from-data', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Auto-generate catchy prescription
  Future<Map<String, dynamic>> autoGenerateCatchyPrescription(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio
          .post('/api/v1/prescriptions/auto-generate-catchy', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // ORDER MANAGEMENT
  // ============================================================

  /// Get patient order history
  Future<List<dynamic>> getPatientOrderHistory(String patientId) async {
    try {
      final response = await _dio.get('/api/v1/orders/patient/$patientId');
      return response.data ?? [];
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  /// Store FCM token
  Future<void> storeFcmToken(String token, String userId) async {
    try {
      await _dio.post('/api/v1/notifications/store-fcm-token', data: {
        'token': token,
        'user_id': userId,
        'user_type': 'doctor',
      });
    } catch (e) {
      debugPrint('Failed to store FCM token: $e');
    }
  }

  // ============================================================
  // TRANSLATION
  // ============================================================

  /// Translate text
  Future<Map<String, dynamic>> translateText(
      String text, String targetLanguage) async {
    try {
      final response = await _dio.post('/api/v1/api/translate/', data: {
        'text': text,
        'target_language': targetLanguage,
      });
      return response.data;
    } catch (e) {
      return {'translated_text': text};
    }
  }

  // ============================================================
  // HEALTH CHECKS
  // ============================================================

  /// Check API health
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Check Brain health
  Future<Map<String, dynamic>> checkBrainHealth() async {
    try {
      final response = await _dio.get('/api/v1/brain/health');
      return response.data;
    } catch (e) {
      return {'status': 'offline'};
    }
  }
}
