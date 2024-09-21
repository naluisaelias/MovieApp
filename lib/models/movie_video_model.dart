class MovieVideo {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;

  MovieVideo({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      id: json['id'],
      key: json['key'],
      name: json['name'],
      site: json['site'],
      type: json['type'],
    );
  }
}

class MovieVideoResult {
  final List<MovieVideo> results;

  MovieVideoResult({required this.results});

  factory MovieVideoResult.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List;
    List<MovieVideo> videoList = list.map((i) => MovieVideo.fromJson(i)).toList();

    return MovieVideoResult(results: videoList);
  }
}
