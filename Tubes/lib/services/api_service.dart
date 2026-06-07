import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://pamdes.my.id/api';
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  static String? token;
  static String? role;
  static String? nama;

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // LOGIN
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (data['status'] == 'success') {
      token = data['token'];
      role  = data['role'];
      nama  = data['nama'];
    }
    return data;
  }

  // LOGOUT
  static Future<void> logout() async {
    await http.post(Uri.parse('$baseUrl/logout'), headers: headers);
    token = null;
    role  = null;
    nama  = null;
  }

  // TAMBAH PELANGGAN (admin)
  static Future<Map<String, dynamic>> tambahPelanggan(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: headers,
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  // INPUT METERAN (admin)
  static Future<Map<String, dynamic>> inputMeteran(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/data/store'),
      headers: headers,
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  // DATA PELANGGAN (pelanggan)
  static Future<Map<String, dynamic>> getDashboardPelanggan() async {
    print('TOKEN SAAT INI: $token'); // ← tambah ini
    final res = await http.get(Uri.parse('$baseUrl/pelanggan'), headers: headers);
    print('PELANGGAN STATUS: ${res.statusCode}');
    print('PELANGGAN BODY: ${res.body}');
    return jsonDecode(res.body);
  }
  // DATA USER (admin)
  static Future<List> getUsersData() async {
    final res = await http.get(Uri.parse('$baseUrl/users'), headers: headers);
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }
  
  static Future<List> getTampilData() async {
    final res = await http.get(Uri.parse('$baseUrl/tampil'), headers: headers);
    print('TAMPIL STATUS: ${res.statusCode}');
    print('TAMPIL BODY: ${res.body}');
    final data = jsonDecode(res.body);
    return data['data']['data'] ?? []; // paginate() Laravel punya nested 'data'
  }

  static Future<Map<String, dynamic>> updateData(String slug, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl/data/$slug'),
      headers: headers,
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteData(String slug) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/data/$slug'),
      headers: headers,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> storeMethodApi(int id, String method) async {
    final res = await http.post(
      Uri.parse('$baseUrl/payment/method'),
      headers: headers,
      body: jsonEncode({'id': id, 'method': method}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteUser(String username) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/users/$username'),
      headers: headers,
    );
    return jsonDecode(res.body);
  }

  // DATA DASHBOARD (admin) — Ambil data untuk jumlah user dan grafik bulanan
  static Future<Map<String, dynamic>> getDashboardAdminData() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/dashboard'), headers: headers);
    final data = jsonDecode(res.body);
    // Mengembalikan data berupa Map Object {}
    return data is Map<String, dynamic> ? data : {};
  }


}