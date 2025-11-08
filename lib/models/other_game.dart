class OtherGame {
  final String name;
  final String imageUrl;
  final String playStoreUrl;
  final String appStoreUrl;

  const OtherGame({
    required this.name,
    required this.imageUrl,
    required this.playStoreUrl,
    required this.appStoreUrl,
  });

  factory OtherGame.fromJson(Map<String, dynamic> json) {
    return OtherGame(
      name: (json['name'] as String?)?.trim() ?? '',
      imageUrl: (json['image'] as String?)?.trim() ?? '',
      playStoreUrl: (json['playstore_url'] as String?)?.trim() ?? '',
      appStoreUrl: (json['appstore_url'] as String?)?.trim() ?? '',
    );
  }

  bool matchesTitle(String title) {
    return name.toLowerCase() == title.trim().toLowerCase();
  }
}

