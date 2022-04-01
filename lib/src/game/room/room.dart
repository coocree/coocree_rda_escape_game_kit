import 'dart:collection';

import 'package:escape_game_kit/src/game/dialog.dart';
import 'package:escape_game_kit/src/game/render/render_settings.dart';
import 'package:escape_game_kit/src/game/room/interactables/interactable.dart';
import 'package:escape_game_kit/src/utils/id_equatable.dart';
import 'package:flutter/material.dart';

class Room with IdEquatable<String>, ChangeNotifier {
  @override
  final String id;
  final RenderSettings? renderSettings;
  final HashSet<Interactable> _interactables;
  final EscapeGameDialog? firstVisitDialog;

  Room({
    required this.id,
    this.renderSettings,
    Iterable<Interactable>? interactables,
    this.firstVisitDialog,
  }) : _interactables = HashSet.from(interactables ?? <Interactable>{});

  HashSet<Interactable> get interactables => HashSet.of(_interactables);

  Interactable? getInteractableFromId(String id) {
    for (Interactable interactable in _interactables) {
      if (interactable.id == id) {
        return interactable;
      }
    }
    return null;
  }

  void addInteractable(Interactable interactable, {bool notify = true}) {
    if (_interactables.add(interactable)) {
      interactable.addListener(notifyListeners);
      if (notify) {
        notifyListeners();
      }
    }
  }

  void removeInteractable(Interactable interactable, {bool notify = true}) {
    if (_interactables.remove(interactable)) {
      interactable.removeListener(notifyListeners);
      if (notify) {
        notifyListeners();
      }
    }
  }

  void removeInteractableFromId(String id, {bool notify = true}) {
    Interactable? interactable = getInteractableFromId(id);
    if (interactable != null) {
      removeInteractable(interactable, notify: notify);
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
