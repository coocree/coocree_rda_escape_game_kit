import 'package:escape_game_kit/escape_game_kit.dart';
import 'package:escape_game_kit_example/game/game.dart';
import 'package:escape_game_kit_example/game/padlocks/bruteforce_padlock.dart';
import 'package:escape_game_kit_example/game/padlocks/caesar_padlock.dart';
import 'package:escape_game_kit_example/game/padlocks/computer_padlock.dart';
import 'package:escape_game_kit_example/game/padlocks/qr_padlock.dart';
import 'package:escape_game_kit_example/widgets/end_message.dart';
import 'package:escape_game_kit_example/widgets/play_button.dart';
import 'package:escape_game_kit_example/widgets/title_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_manager/window_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)) {
    adjustWindowSize();
  }
  registerPadlocks();
  Error1980EscapeGame escapeGame = Error1980EscapeGame();
  runApp(_EscapeGameKitExample(escapeGame: escapeGame));
}

Future<void> adjustWindowSize() async {
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    Size size = const Size(990, 430);
    await windowManager.setSize(size);
    await windowManager.setMinimumSize(size);
    await windowManager.setMaximumSize(size);
    await windowManager.setResizable(false);
    await windowManager.center();
    await windowManager.show();
  });
}

void registerPadlocks() {
  PadlockDialogs.registerBuilderFor(
    CredentialsPadlock,
    (context, padlock) => CredentialsPadlockDialog.builder(
      context,
      padlock,
      usernameText: "Nom d'utilisateur",
      passwordText: 'Mot de passe',
    ),
  );
  PadlockDialogs.registerBuilderFor(BruteforcePadlock, BruteforcePadlockDialog.builder);
  PadlockDialogs.registerBuilderFor(CaesarPadlock, CaesarPadlockDialog.builder);
  PadlockDialogs.registerBuilderFor(ComputerPadlock, ComputerPadlockDialog.builder);
  PadlockDialogs.registerBuilderFor(QrPadlock, QrPadlockDialog.builder);
}

class _EscapeGameKitExample extends StatefulWidget {
  final EscapeGame escapeGame;

  const _EscapeGameKitExample({
    required this.escapeGame,
  });

  @override
  State<StatefulWidget> createState() => _EscapeGameKitExampleState();
}

class _EscapeGameKitExampleState extends State<_EscapeGameKitExample> {
  @override
  void initState() {
    super.initState();
    for (String asset in [
      'assets/backgrounds/bedroom.png',
      'assets/backgrounds/bedroom-present.png',
      'assets/backgrounds/desk.png',
      'assets/backgrounds/living-room.png',
      'assets/glitch/image.webp',
    ]) {
      precacheImage(AssetImage(asset), context);
    }
    for (String asset in [
      'assets/interactables/arrow.svg',
      'assets/interactables/bed-key.svg',
      'assets/interactables/bookshelf-key.svg',
      'assets/interactables/desk-key.svg',
      'assets/padlocks/caesar-1.svg',
      'assets/padlocks/caesar-2.svg',
    ]) {
      precachePicture(ExactAssetPicture(SvgPicture.svgStringDecoderBuilder, asset), context);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'EscapeGameKit Example',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scrollbarTheme: const ScrollbarThemeData(isAlwaysShown: true),
        ),
        locale: const Locale('fr'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr')],
        home: EscapeGameWidget(
          beforeGameStartBuilder: (context, escapeGame) => TitleScreen(
            child: PlayButton(
              escapeGame: escapeGame,
            ),
          ),
          afterGameFinishedBuilder: (context, escapeGame) => const TitleScreen(
            child: EndMessage(),
          ),
          escapeGame: widget.escapeGame,
        ),
      );
}
