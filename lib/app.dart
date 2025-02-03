import "package:desktop_updater/desktop_updater.dart";
import "package:desktop_updater/updater_controller.dart";
import "package:flutter/material.dart";
import "package:package_info_plus/package_info_plus.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentVersion = "Unknown";
  String? _newVersion;
  String? _changelog;
  bool _isUpdateAvailable = false;

  late DesktopUpdaterController _updaterController;

  @override
  void initState() {
    super.initState();
    _checkAppVersion();

    _updaterController = DesktopUpdaterController(
      appArchiveUrl: Uri.parse(
        "https://raw.githubusercontent.com/flyboy13/ota_linux/refs/heads/master/lib/app-archive.json",
      ),
      localization: const DesktopUpdateLocalization(
        updateAvailableText: "Update available",
        newVersionAvailableText: "{} {} is available",
        newVersionLongText: "New version is ready to download. This will download {} MB of data.",
        restartText: "Restart to update",
        warningTitleText: "Are you sure?",
        restartWarningText:
            "A restart is required to complete the update installation.\nAny unsaved changes will be lost. Restart now?",
        warningCancelText: "Not now",
        warningConfirmText: "Restart",
      ),
    );

    _checkForUpdates();
  }

  Future<void> _checkAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _currentVersion = packageInfo.version;
      });
    } catch (e) {
      setState(() {
        _currentVersion = "Unknown";
      });
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      // await _updaterController.checkVersion();
      if (_updaterController.appVersion != _currentVersion) {
        setState(() {
          _newVersion = _updaterController.appVersion;
          _changelog = _updaterController.releaseNotes?.map((e) => e?.message).join("\n");
          _isUpdateAvailable = true;
        });
      }
    } catch (e) {
      if (e is FormatException) {
        // Handle the FormatException
        print("Failed to parse response: ${e.message}");
      } else {
        // Handle other exceptions
        print("An error occurred: $e");
      }
      setState(() {
        _isUpdateAvailable = false;
      });
    }
  }

  void _startUpdate() {
    _updaterController.downloadUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OTA Update Example")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Current Version: $_currentVersion"),
              if (_isUpdateAvailable)
                Column(
                  children: [
                    Text(
                      "New Version Available: $_newVersion",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_changelog != null) Text("Changelog: $_changelog"),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _startUpdate, child: const Text("Download & Update")),
                  ],
                )
              else
                const Text("Your app is up to date!"),
            ],
          ),
        ),
      ),
    );
  }
}
