import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiFailure implements Exception {
  const ApiFailure(this.status, this.message, {this.retryAfterSeconds});
  final int? retryAfterSeconds;
  final int status;
  final String message;
  @override
  String toString() => message;
}

class ApiSession {
  const ApiSession({
    required this.baseUrl,
    required this.token,
    required this.userId,
    required this.organizationId,
    required this.name,
    required this.role,
  });
  final String baseUrl, token, userId, organizationId, name, role;
  String scope(String farmId) => '$baseUrl|$organizationId|$userId|$farmId';
  Map<String, dynamic> toJson() => {
    'baseUrl': baseUrl,
    'token': token,
    'userId': userId,
    'organizationId': organizationId,
    'name': name,
    'role': role,
  };
  factory ApiSession.fromJson(Map<String, dynamic> json) => ApiSession(
    baseUrl: json['baseUrl'],
    token: json['token'],
    userId: json['userId'],
    organizationId: json['organizationId'],
    name: json['name'],
    role: json['role'],
  );
}

class OperationsApi {
  OperationsApi(String baseUrl, {http.Client? client})
    : baseUrl = validateUrl(baseUrl),
      _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;
  static String validateUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.scheme != 'https' &&
            !(uri.scheme == 'http' &&
                ['localhost', '127.0.0.1', '10.0.2.2'].contains(uri.host)))) {
      throw const ApiFailure(
        0,
        'Use uma URL HTTPS da API (HTTP somente para desenvolvimento local).',
      );
    }
    return uri.toString().replaceFirst(RegExp(r'/+$'), '');
  }

  Future<dynamic> request(
    String method,
    String path, {
    String? token,
    Object? body,
  }) async {
    final headers = {
      'content-type': 'application/json',
      if (token != null) 'authorization': 'Bearer $token',
    };
    http.Response response;
    try {
      final uri = Uri.parse('$baseUrl$path');
      response = await (switch (method) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(uri, headers: headers, body: jsonEncode(body)),
        'PATCH' => _client.patch(uri, headers: headers, body: jsonEncode(body)),
        _ => throw ArgumentError('Método HTTP não permitido'),
      }).timeout(const Duration(seconds: 45));
    } catch (_) {
      throw const ApiFailure(
        0,
        'API sem resposta. O registro continua salvo no aparelho.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiFailure(
        response.statusCode,
        switch (response.statusCode) {
          401 =>
            'Sessão expirada ou credenciais inválidas. Conecte novamente; a fila foi preservada.',
          403 =>
            'Acesso ou aparelho recusado pela API. Verifique o cadastro com o administrador.',
          404 => 'Recurso ainda não disponível na API.',
          429 =>
            'API limitou as tentativas. Aguarde antes de sincronizar novamente.',
          _ =>
            'API respondeu ${response.statusCode}. Nenhum evento foi descartado.',
        },
        retryAfterSeconds: int.tryParse(response.headers['retry-after'] ?? ''),
      );
    }
    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw const ApiFailure(
        0,
        'Resposta inválida da API; confirmação não reconhecida.',
      );
    }
  }

  Future<ApiSession> login(String email, String password) async {
    final json = await request(
      'POST',
      '/v1/auth/login',
      body: {'email': email.trim(), 'password': password},
    );
    try {
      final token = json['accessToken'] as String;
      final claims = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))),
      );
      final user = json['user'];
      return ApiSession(
        baseUrl: baseUrl,
        token: token,
        userId: user['id'],
        organizationId: claims['org'] as String,
        name: user['name'],
        role: user['role'],
      );
    } catch (_) {
      throw const ApiFailure(
        0,
        'Resposta de autenticação incompatível com o contrato.',
      );
    }
  }

  Future<void> setTaskStatus(
    ApiSession session,
    String taskId,
    String status,
  ) async {
    final response = await request(
      'PATCH',
      '/v1/tasks/$taskId/status',
      token: session.token,
      body: {'status': status},
    );
    if (response is! Map ||
        response['id'] != taskId ||
        response['status'] != status) {
      throw const ApiFailure(
        0,
        'A API não confirmou o status desta tarefa. Atualize a lista antes de tentar novamente.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> list(
    String path,
    ApiSession session,
  ) async => (await request('GET', path, token: session.token) as List)
      .cast<Map<String, dynamic>>();
  Future<String> send(
    ApiSession session,
    String farmId,
    String deviceId,
    Map<String, dynamic> event,
  ) async {
    final json = await request(
      'POST',
      '/v1/sync/events',
      token: session.token,
      body: {
        'farmId': farmId,
        'deviceId': deviceId,
        'events': [event],
      },
    );
    final acks = json is Map ? json['acks'] : null;
    if (acks is! List ||
        acks.length != 1 ||
        acks.single is! Map ||
        acks.single['id'] != event['id']) {
      throw const ApiFailure(
        0,
        'ACK inválido ou sem o ID do evento. A fila foi preservada.',
      );
    }
    final ack = acks.single;
    if (ack['status'] == 'rejected') {
      throw ApiFailure(
        422,
        'Evento rejeitado: ${ack['reason'] ?? 'revise o registro'}',
      );
    }
    if (!['accepted', 'duplicate'].contains(ack['status'])) {
      throw const ApiFailure(0, 'Status de ACK desconhecido.');
    }
    return ack['status'] as String;
  }

  void close() => _client.close();
}
