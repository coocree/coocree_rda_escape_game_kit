import 'package:escape_game_kit/src/game/game.dart';
import 'package:escape_game_kit/src/game/room/room.dart';
import 'package:escape_game_kit/src/widgets/alert_dialog.dart';
import 'package:escape_game_kit/src/widgets/inventory/button.dart';
import 'package:escape_game_kit/src/widgets/render_settings_stack.dart';
import 'package:escape_game_kit/src/widgets/room/room.dart';
import 'package:escape_game_kit/src/widgets/room_transition.dart';
import 'package:flutter/material.dart';

typedef GameWidgetBuilder = Widget Function(BuildContext context, EscapeGame escapeGame);
typedef RoomWidgetBuilder = Widget Function(BuildContext context, EscapeGame escapeGame, Room room);
typedef TryExitCallback = Future<bool> Function(EscapeGame escapeGame);
typedef RoomTransitionBuilder = RoomTransition Function(EscapeGame escapeGame, Room? previousRoom, Room newRoom);

class EscapeGameWidget extends StatefulWidget {
  final EscapeGame escapeGame;
  final GameWidgetBuilder? beforeGameStartBuilder;
  final RoomWidgetBuilder roomWidgetBuilder;
  final GameWidgetBuilder inventoryWidgetBuilder;
  final GameWidgetBuilder? afterGameFinishedBuilder;
  final TryExitCallback? onTryToExit;
  final RoomTransitionBuilder roomTransitionBuilder;

  const EscapeGameWidget({
    Key? key,
    required this.escapeGame,
    this.beforeGameStartBuilder,
    this.roomWidgetBuilder = defaultRoomWidgetBuilder,
    this.inventoryWidgetBuilder = defaultInventoryWidgetBuilder,
    this.afterGameFinishedBuilder,
    this.onTryToExit,
    this.roomTransitionBuilder = defaultRoomTransitionBuilder,
  }) : super(
          key: key,
        );

  @override
  State<StatefulWidget> createState() => _EscapeGameWidgetState();

  static Widget defaultRoomWidgetBuilder(BuildContext context, EscapeGame escapeGame, Room room) => RoomWidget(
        escapeGame: escapeGame,
        room: room,
      );

  static Widget defaultInventoryWidgetBuilder(BuildContext context, EscapeGame escapeGame) => InventoryButton(
        escapeGame: escapeGame,
      );

  static RoomTransition defaultRoomTransitionBuilder(EscapeGame escapeGame, Room? previousRoom, Room newRoom) => const RoomTransition();
}

class _EscapeGameWidgetState extends State<EscapeGameWidget> {
  RoomTransition roomTransition = const RoomTransition();
  bool isDialogOpened = false;
  Room? currentRoom;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      refreshCurrentRoom();
      refreshDialog();
      widget.escapeGame.addListener(refreshCurrentRoom);
      widget.escapeGame.addListener(refreshDialog);
    });
  }

  @override
  void didUpdateWidget(covariant EscapeGameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.escapeGame != widget.escapeGame || oldWidget.escapeGame.currentRoom != widget.escapeGame.currentRoom || oldWidget.escapeGame.openedDialog != widget.escapeGame.openedDialog) {
      refreshCurrentRoom();
      refreshDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!widget.escapeGame.isStarted && widget.beforeGameStartBuilder != null) {
      child = widget.beforeGameStartBuilder!(context, widget.escapeGame);
    } else if (widget.escapeGame.isFinished && widget.afterGameFinishedBuilder != null) {
      child = widget.afterGameFinishedBuilder!(context, widget.escapeGame);
    } else if (currentRoom != null) {
      child = widget.roomWidgetBuilder(context, widget.escapeGame, currentRoom!);

      if (widget.escapeGame.inventory.renderSettings != null) {
        child = Stack(
          key: ValueKey('stack-room-${currentRoom!.id}'),
          children: [
            child,
            RenderSettingsStackWidget(
              renderSettings: widget.escapeGame.inventory.renderSettings,
              child: widget.inventoryWidgetBuilder(context, widget.escapeGame),
            ),
          ],
        );
      }
    } else {
      child = const SizedBox.shrink();
    }

    return WillPopScope(
      onWillPop: widget.onTryToExit == null ? null : () => widget.onTryToExit!(widget.escapeGame),
      child: roomTransition.createAnimatedSwitch(child: child),
    );
  }

  @override
  void dispose() {
    widget.escapeGame.removeListener(refreshCurrentRoom);
    widget.escapeGame.removeListener(refreshDialog);
    super.dispose();
  }

  Future<void> refreshDialog() async {
    if (mounted && widget.escapeGame.isDialogOpened && !isDialogOpened) {
      isDialogOpened = true;
      await showDialog(
        context: context,
        builder: (context) => EscapeGameAlertDialog.fromEscapeGameDialog(escapeGameDialog: widget.escapeGame.openedDialog!),
      );
      isDialogOpened = false;
    }
  }

  void refreshCurrentRoom() {
    if (mounted) {
      setState(() {
        roomTransition = widget.roomTransitionBuilder(widget.escapeGame, currentRoom, widget.escapeGame.currentRoom);
        currentRoom = widget.escapeGame.currentRoom;
      });
    }
  }
}
