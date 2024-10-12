import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_update/azhon_app_update.dart';
import 'package:flutter_app_update/update_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Updater {
  late Release latestRelease;
  SharedPreferences? prefs;

  Future<bool> isUpdateAvailable() async {
    prefs ??= await SharedPreferences.getInstance();

    // Check if last checked is more than 1 day ago
    String? lastChecked = prefs?.getString('lastChecked');
    if (lastChecked != null && !kDebugMode) {
      DateTime lastCheckedDate = DateTime.parse(lastChecked);
      if (DateTime.now().difference(lastCheckedDate).inDays < 1) {
        return false;
      }
    }

    // Get latest release version from GitHub API
    String username = 'sruusk';
    String packageName = 'flutter-menu';
    String url = 'https://api.github.com/repos/$username/$packageName/releases/latest';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var decoded = utf8.decode(response.bodyBytes);
      var latestRelease = Release.fromJson(json.decode(decoded));

      // Save latest release for later use
      this.latestRelease = latestRelease;

      // Save last checked date
      prefs?.setString('lastChecked', DateTime.now().toString());

      // Get current version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      AppVersion currentVersion = AppVersion.fromString(packageInfo.version);
      // Compare versions
      if (latestRelease.version > currentVersion) {
        if(kDebugMode) {
          print('Update available: ${latestRelease.version} > ${currentVersion}');
        }
        return true;
      } else if(kDebugMode) {
        print('No update available: ${latestRelease.version} <= ${currentVersion}');
      }
    } else {
      if (kDebugMode) {
        print('Failed to load latest release, status code: ${response.statusCode}');
        print(response.body);
      }
    }

    return false;
  }

  void downloadAndInstallUpdate() {
    // Download and install update
    print('Download update from ${latestRelease.downloadUrl}');

    if(latestRelease.downloadUrl == null) {
      return;
    }

    AzhonAppUpdate.listener((map) {
      debugPrint('app update listener: ${jsonEncode(map)}');
    });

    UpdateModel model = UpdateModel(
      latestRelease.downloadUrl,
      "app-release.apk",
      "ic_launcher",
      "com.sruusk.flutter_menu",
    );
    AzhonAppUpdate.update(model);
  }
}



class Release {
  final AppVersion version;
  final String downloadUrl;

  Release({required this.version, required this.downloadUrl});

  factory Release.fromJson(Map<String, dynamic> json) {
    return Release(
      version: AppVersion.fromString(json['tag_name']),
      downloadUrl: json['assets'][0]['browser_download_url'],
    );
  }

  @override
  String toString() {
    return 'Release{version: $version, downloadUrl: $downloadUrl}';
  }
}

class AppVersion {
  final num major;
  final num minor;
  final num patch;

  AppVersion({required this.major, required this.minor, required this.patch});

  factory AppVersion.fromString(String version) {
    var parts = version.replaceAll("v", '').replaceAll(RegExp(r'(\+\d)'), "").split('.');
    return AppVersion(major: num.parse(parts[0]), minor: num.parse(parts[1]), patch: num.parse(parts[2]));
  }

  // Compare two versions
  bool operator >(AppVersion other) {
    if (major > other.major) {
      return true;
    } else if (major == other.major) {
      if (minor > other.minor) {
        return true;
      } else if (minor == other.minor) {
        if (patch > other.patch) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  String toString() {
    return '$major.$minor.$patch';
  }
}
