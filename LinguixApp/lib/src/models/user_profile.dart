class UserProfile {
  String id;
  String name;
  String avatar;
  String country;
  int xp;
  int streak;
  List<String> badges;
  List<String> languages;
  Map<String, dynamic> progress;

  UserProfile({
    required this.id,
    required this.name,
    this.avatar = '',
    this.country = '',
    this.xp = 0,
    this.streak = 0,
    this.badges = const [],
    this.languages = const [],
    this.progress = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'country': country,
    'xp': xp,
    'streak': streak,
    'badges': badges,
    'languages': languages,
    'progress': progress,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    avatar: json['avatar'] ?? '',
    country: json['country'] ?? '',
    xp: json['xp'] ?? 0,
    streak: json['streak'] ?? 0,
    badges: List<String>.from(json['badges'] ?? []),
    languages: List<String>.from(json['languages'] ?? []),
    progress: json['progress'] ?? {},
  );
}