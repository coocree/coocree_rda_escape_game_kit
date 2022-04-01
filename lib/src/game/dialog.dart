import 'package:escape_game_kit/src/game/render/render_settings.dart';

class EscapeGameDialog {
  final String? title;
  final RenderSettings? imageRenderSettings;
  final String message;

  const EscapeGameDialog({
    this.title,
    this.imageRenderSettings,
    required this.message,
  });
}