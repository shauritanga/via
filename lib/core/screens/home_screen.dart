import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../features/voice_commands/presentation/widgets/voice_command_integration.dart';
import '../navigation/app_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return VoiceCommandIntegration(
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: _buildBottomNavigationBar(localizations),
      ),
    );
  }

  Widget _buildBottomNavigationBar(AppLocalizations localizations) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.description_outlined),
          selectedIcon: const Icon(Icons.description),
          label: localizations.documents,
        ),
        NavigationDestination(
          icon: const Icon(Icons.mic_outlined),
          selectedIcon: const Icon(Icons.mic),
          label: localizations.voiceCommands,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: localizations.settings,
        ),
      ],
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go(AppRoutes.documents);
        break;
      case 1:
        context.go(AppRoutes.voiceCommands);
        break;
      case 2:
        context.go(AppRoutes.settings);
        break;
    }
  }
}
