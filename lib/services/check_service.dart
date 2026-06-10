import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

class CheckResult {
  final int? statusCode;
  final bool isAvailable;
  final int pingMs;

  CheckResult({
    this.statusCode,
    required this.isAvailable,
    required this.pingMs,
  });
}

class CheckService {
  /// Determine if the target is a URL or just a host/IP.
  static bool _looksLikeUrl(String input) {
    return input.startsWith('http://') || input.startsWith('https://');
  }

  static String _normalizeUrl(String input) {
    if (_looksLikeUrl(input)) return input;
    // If it's like example.com or 1.2.3.4, assume http://
    return 'http://$input';
  }

  /// Try to parse input as host:port (TCP), including bracketed IPv6 [::1]:443
  static (String host, int port)? _parseHostPort(String input) {
    // Ignore if it's already a URL with a scheme
    if (input.contains('://')) return null;
    // Bracketed IPv6
    if (input.startsWith('[')) {
      final close = input.indexOf(']');
      if (close > 0 && close < input.length - 1 && input[close + 1] == ':') {
        final host = input.substring(1, close);
        final portStr = input.substring(close + 2);
        final port = int.tryParse(portStr);
        if (port != null) return (host, port);
      }
      return null;
    }
    // Otherwise, look for the last ':' and see if it's a numeric port
    final idx = input.lastIndexOf(':');
    if (idx > 0 && idx < input.length - 1) {
      final host = input.substring(0, idx);
      final portStr = input.substring(idx + 1);
      final port = int.tryParse(portStr);
      if (port != null) return (host, port);
    }
    return null;
  }

  /// Perform a quick availability check and measure latency.
  /// - If URL: send a HEAD then fallback to GET; measure time to first byte.
  /// - If plain host/IP: attempt a TCP connect to port 80 (HTTP) with timeout.
  static Future<CheckResult> check(
    String target, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final sw = Stopwatch()..start();
    try {
      // 1) Explicit URL (http/https)
      if (_looksLikeUrl(target)) {
        final url = Uri.parse(target);
        try {
          final headResp = await http.head(url).timeout(timeout);
          sw.stop();
          return CheckResult(
            statusCode: headResp.statusCode,
            isAvailable:
                headResp.statusCode >= 200 && headResp.statusCode < 500,
            pingMs: sw.elapsedMilliseconds,
          );
        } on Exception {
          // fallback to GET
          final getResp = await http.get(url).timeout(timeout);
          sw.stop();
          return CheckResult(
            statusCode: getResp.statusCode,
            isAvailable: getResp.statusCode >= 200 && getResp.statusCode < 500,
            pingMs: sw.elapsedMilliseconds,
          );
        }
      }

      // 2) host:port (TCP) e.g., example.com:443, 1.2.3.4:22, [::1]:8080
      final hp = _parseHostPort(target);
      if (hp != null) {
        final socket = await Socket.connect(hp.$1, hp.$2, timeout: timeout);
        await socket.close();
        sw.stop();
        return CheckResult(
          statusCode: null,
          isAvailable: true,
          pingMs: sw.elapsedMilliseconds,
        );
      }

      // 3) Plain host/IP -> HTTP check to default port using normalized URL
      final url = Uri.parse(_normalizeUrl(target));
      try {
        final headResp = await http.head(url).timeout(timeout);
        sw.stop();
        return CheckResult(
          statusCode: headResp.statusCode,
          isAvailable: headResp.statusCode >= 200 && headResp.statusCode < 500,
          pingMs: sw.elapsedMilliseconds,
        );
      } on Exception {
        // fallback to GET
        final getResp = await http.get(url).timeout(timeout);
        sw.stop();
        return CheckResult(
          statusCode: getResp.statusCode,
          isAvailable: getResp.statusCode >= 200 && getResp.statusCode < 500,
          pingMs: sw.elapsedMilliseconds,
        );
      }
    } catch (_) {
      sw.stop();
      return CheckResult(
        statusCode: null,
        isAvailable: false,
        pingMs: sw.elapsedMilliseconds,
      );
    }
  }
}
