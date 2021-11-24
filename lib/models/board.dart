import 'package:flutter/material.dart';
import 'package:flutter_stateless_chessboard/models/blocked_square.dart';
import 'package:flutter_stateless_chessboard/models/piece.dart';
import 'package:flutter_stateless_chessboard/utils.dart' as utils;
import 'package:fpdart/fpdart.dart';

import 'board_color.dart';
import 'piece_type.dart';
import 'short_move.dart';
import 'square.dart';

typedef Promoted = Future<PieceType?> Function();
typedef Moved = void Function(ShortMove move);
typedef BuildPiece = Widget? Function(Piece piece, double size);

class Board {
  final String fen;
  final double size;
  final BoardColor orientation;
  final Color lightSquareColor;
  final Color darkSquareColor;
  final Moved _onMove;
  final Promoted _onPromote;
  final Option<BuildPiece> buildPiece;
  final List<BlockedSquare> blockedSquares;

  Board({
    required this.fen,
    required this.size,
    required this.orientation,
    required this.lightSquareColor,
    required this.darkSquareColor,
    required Moved onMove,
    required Promoted onPromote,
    required this.blockedSquares,
    BuildPiece? buildPiece,
  })  : _onMove = onMove,
        _onPromote = onPromote,
        buildPiece = Option.fromNullable(buildPiece);

  double get squareSize => size / 8;

  List<Square> get squares => utils.getSquares(this);

  Future<void> makeMove(ShortMove move) async {
    if (utils.isPromoting(fen, move)) {
      final pieceType = await promotion;
      return pieceType.match(
        (t) {
          _onMove(ShortMove(
            from: move.from,
            to: move.to,
            promotion: Option.of(t),
          ));
        },
        () => Future.error("Move cancelled"),
      );
    } else {
      _onMove(move);
    }
  }

  Future<Option<PieceType>> get promotion async {
    return Option.fromNullable(await _onPromote()).map(
      (t) => t == PieceType.KING || t == PieceType.PAWN ? PieceType.QUEEN : t,
    );
  }
}
