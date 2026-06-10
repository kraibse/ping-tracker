class CheckVisual {
  final String target;
  final bool available;
  final int pingMs;
  final int? status;
  final bool isLoading;

  const CheckVisual({
    required this.target,
    required this.available,
    required this.pingMs,
    required this.status,
    this.isLoading = false,
  });

  factory CheckVisual.from(dynamic res, String target) => CheckVisual(
    target: target,
    available: res.isAvailable,
    pingMs: res.pingMs,
    status: res.statusCode,
    isLoading: false,
  );

  factory CheckVisual.loading(String target) => CheckVisual(
    target: target,
    available: false,
    pingMs: 0,
    status: null,
    isLoading: true,
  );
}
