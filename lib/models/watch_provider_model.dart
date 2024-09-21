class WatchProvider {
  final String providerName;
  final int providerId;

  WatchProvider({required this.providerName, required this.providerId});

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      providerName: json['provider_name'] as String,
      providerId: json['provider_id'] as int,
    );
  }
}

class WatchProviderResult {
  final Map<String, List<WatchProvider>> results;

  WatchProviderResult({required this.results});

  factory WatchProviderResult.fromJson(Map<String, dynamic> json) {
    final providers = (json['results'] as Map<String, dynamic>).map(
      (key, value) {
        // Verifique se a chave "flatrate" existe e é uma lista
        final flatrateList = value['flatrate'] as List<dynamic>? ?? [];
        return MapEntry(
          key,
          flatrateList.map((item) => WatchProvider.fromJson(item)).toList(),
        );
      },
    );
    return WatchProviderResult(results: providers);
  }
}
