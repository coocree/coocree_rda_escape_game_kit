import 'dart:collection';

import 'package:escape_game_kit/src/game/room/interactables/interactable.dart';
import 'package:escape_game_kit/src/game/padlocks/padlock.dart';
import 'package:escape_game_kit/src/game/render/render_settings.dart';
import 'package:escape_game_kit/src/widgets/room/background.dart';
import 'package:flutter/material.dart';

class Room with ChangeNotifier {
  final String id;
  final RenderSettings? renderSettings;
  final HashSet<Interactable> _interactables;

  Room({
    required this.id,
    this.renderSettings,
    Iterable<Interactable>? interactables,
  }) : _interactables = HashSet.from(interactables ?? <Interactable>{});

  HashSet<Interactable> get interactables => HashSet.of(_interactables);

  void addInteractable(Interactable interactable) {
    if(_interactables.add(interactable)) {
      interactable.addListener(notifyListeners);
    }
  }

  void removeInteractable(Interactable interactable) {
    if(_interactables.remove(interactable)) {
      interactable.removeListener(notifyListeners);
    }
  }

  @override
  void dispose() {
    for (Interactable interactable in _interactables) {
      interactable.dispose();
    }
    super.dispose();
  }
}