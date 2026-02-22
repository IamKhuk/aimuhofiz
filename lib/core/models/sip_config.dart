class SipConfig {
  final String wssUrl;
  final String sipUri;
  final String authorizationUser;
  final String password;
  final String displayName;
  final String? realm;
  final List<Map<String, String>> iceServers;

  const SipConfig({
    required this.wssUrl,
    required this.sipUri,
    required this.authorizationUser,
    required this.password,
    this.displayName = 'FiribLock User',
    this.realm,
    this.iceServers = const [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  });

  factory SipConfig.fromJson(Map<String, dynamic> json) {
    return SipConfig(
      wssUrl: json['wss_url'] as String,
      sipUri: json['sip_uri'] as String,
      authorizationUser: json['authorization_user'] as String,
      password: json['password'] as String,
      displayName: json['display_name'] as String? ?? 'FiribLock User',
      realm: json['realm'] as String?,
      iceServers: (json['ice_servers'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          const [
            {'urls': 'stun:stun.l.google.com:19302'},
          ],
    );
  }

  Map<String, dynamic> toJson() => {
        'wss_url': wssUrl,
        'sip_uri': sipUri,
        'authorization_user': authorizationUser,
        'password': password,
        'display_name': displayName,
        'realm': realm,
        'ice_servers': iceServers,
      };
}
