/// A record to represent a specific edge on the board
class GameEdge {
  final String type;
  final int i;
  final int j;

  const GameEdge({required this.type, required this.i, required this.j});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameEdge &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          i == other.i &&
          j == other.j;

  @override
  int get hashCode => type.hashCode ^ i.hashCode ^ j.hashCode;
}
