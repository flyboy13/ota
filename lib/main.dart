import "package:flutter/material.dart";

import "package:desktop_updater/desktop_updater.dart";
import "package:desktop_updater/updater_controller.dart";
import "package:package_info_plus/package_info_plus.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentVersion = "Unknown";

  late DesktopUpdaterController _updaterController;

  @override
  void initState() {
    super.initState();
    _checkAppVersion();

    _updaterController = DesktopUpdaterController(
      appArchiveUrl: Uri.parse(
        "https://raw.githubusercontent.com/flyboy13/ota/refs/heads/master/lib/app-archive.json",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your App Home Page")),
      body: DesktopUpdateWidget(
        controller: _updaterController,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[const Text('Hello World!')],
          ),
        ),
      ),
    );
  }
}
