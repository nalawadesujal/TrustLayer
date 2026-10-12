import 'dart:io';

class ApiEndpoints {
    // Dynamic IP resolution for Android Emulator (10.0.2.2) vs iOS Simulator (localhost)
    static String get baseUrl {
        if (Platform.isAndroid) {
            return "http://10.0.2.2:5000/api";
        }
        return "http://localhost:5000/api";
    }

    // Auth paths
    static String get register => "$baseUrl/auth/register";
    static String get login => "$baseUrl/auth/login";

    // Detection paths
    static String get detectText => "$baseUrl/detect/text";
    static String get detectImage => "$baseUrl/detect/image";
    static String get detectVoice => "$baseUrl/detect/voice";

    // History paths
    static String get history => "$baseUrl/history";
    static String deleteHistoryItem(int id) => "$baseUrl/history/$id";
}
