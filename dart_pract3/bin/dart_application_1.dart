import 'dart:io';
import 'dart:math';

const int boardSize = 10;
const List<int> shipSizes = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];

enum CellState {
  empty('~'),
  ship('S'),
  hit('X'),
  miss('O'),
  marked('M');

  final String symbol;
  const CellState(this.symbol);
}

class Board {
  List<List<CellState>> grid;
  List<Ship> ships;

  Board() : grid = List.generate(boardSize, (_) => List.filled(boardSize, CellState.empty)), ships = [];

  void placeShipsRandomly() {
    ships.clear();
    Random rand = Random();
    for (int size in shipSizes) {
      bool placed = false;
      while (!placed) {
        int row = rand.nextInt(boardSize);
        int col = rand.nextInt(boardSize);
        bool horizontal = rand.nextBool();
        if (canPlaceShip(row, col, size, horizontal)) {
          placeShip(row, col, size, horizontal);
          placed = true;
        }
      }
    }
  }

  bool canPlaceShip(int row, int col, int size, bool horizontal) {
    if (horizontal) {
      if (col + size > boardSize) return false;
      for (int i = 0; i < size; i++) {
        if (grid[row][col + i] != CellState.empty) return false;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int nr = row + dr;
            int nc = col + i + dc;
            if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize && grid[nr][nc] == CellState.ship) {
              return false;
            }
          }
        }
      }
    } else {
      if (row + size > boardSize) return false;
      for (int i = 0; i < size; i++) {
        if (grid[row + i][col] != CellState.empty) return false;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int nr = row + i + dr;
            int nc = col + dc;
            if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize && grid[nr][nc] == CellState.ship) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  void placeShip(int row, int col, int size, bool horizontal) {
    Ship ship = Ship(row, col, size, horizontal);
    ships.add(ship);
    if (horizontal) {
      for (int i = 0; i < size; i++) {
        grid[row][col + i] = CellState.ship;
      }
    } else {
      for (int i = 0; i < size; i++) {
        grid[row + i][col] = CellState.ship;
      }
    }
  }

  bool allShipsSunk() {
    return ships.every((ship) => ship.isSunk(grid));
  }

  AttackResult attack(int row, int col) {
    if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) {
      return AttackResult.invalid;
    }
    if (grid[row][col] == CellState.hit || grid[row][col] == CellState.miss || grid[row][col] == CellState.marked) {
      return AttackResult.alreadyAttacked;
    }
    if (grid[row][col] == CellState.ship) {
      grid[row][col] = CellState.hit;
      Ship? hitShip = ships.firstWhere((ship) => ship.contains(row, col), orElse: () => Ship(-1, -1, 0, false));
      if (hitShip.isSunk(grid)) {
        markAroundSunkShip(hitShip);
        return AttackResult.sunk;
      }
      return AttackResult.hit;
    } else {
      grid[row][col] = CellState.miss;
      return AttackResult.miss;
    }
  }

  void markAroundSunkShip(Ship ship) {
    int minRow = max(0, ship.row - 1);
    int maxRow = min(boardSize - 1, ship.row + (ship.horizontal ? 0 : ship.size - 1) + 1);
    int minCol = max(0, ship.col - 1);
    int maxCol = min(boardSize - 1, ship.col + (ship.horizontal ? ship.size - 1 : 0) + 1);

    for (int r = minRow; r <= maxRow; r++) {
      for (int c = minCol; c <= maxCol; c++) {
        if (grid[r][c] == CellState.empty) {
          grid[r][c] = CellState.marked;
        }
      }
    }
  }

  int getRemainingShips() {
    return ships.where((ship) => !ship.isSunk(grid)).length;
  }

  int getRemainingShipCells() {
    return ships.fold(0, (sum, ship) {
      if (!ship.isSunk(grid)) {
        return sum + ship.size;
      }
      return sum;
    });
  }

  void display({bool hideShips = false}) {
    print('  A B C D E F G H I J');
    for (int i = 0; i < boardSize; i++) {
      stdout.write('${i + 1 < 10 ? ' ' : ''}${i + 1}');
      for (int j = 0; j < boardSize; j++) {
        CellState state = grid[i][j];
        String symbol = state.symbol;
        if (hideShips && state == CellState.ship) {
          symbol = CellState.empty.symbol;
        } else if (state == CellState.marked) {
          symbol = CellState.miss.symbol;
        }
        stdout.write(' $symbol');
      }
      print('');
    }
  }
}

class Ship {
  int row, col, size;
  bool horizontal;

  Ship(this.row, this.col, this.size, this.horizontal);

  bool contains(int r, int c) {
    if (horizontal) {
      return r == row && c >= col && c < col + size;
    } else {
      return c == col && r >= row && r < row + size;
    }
  }

  bool isSunk(List<List<CellState>> grid) {
    if (horizontal) {
      for (int i = 0; i < size; i++) {
        if (grid[row][col + i] != CellState.hit) return false;
      }
    } else {
      for (int i = 0; i < size; i++) {
        if (grid[row + i][col] != CellState.hit) return false;
      }
    }
    return true;
  }
}

enum AttackResult { hit, miss, sunk, alreadyAttacked, invalid }

class GameStats {
  int player1Shots = 0;
  int player1Hits = 0;
  int player1Misses = 0;
  int player1SunkShips = 0;
  int player2Shots = 0;
  int player2Hits = 0;
  int player2Misses = 0;
  int player2SunkShips = 0;
  String winner = '';
  int player1RemainingShips = 0;
  int player2RemainingShips = 0;
  int player1RemainingCells = 0;
  int player2RemainingCells = 0;

  void saveToFile(String directory, String filename) {
    Directory(directory).createSync(recursive: true);
    File file = File('$directory/$filename');
    String content = '''
Game Statistics
---------------
Winner: $winner
Player 1:
  Total Shots: $player1Shots
  Hits: $player1Hits
  Misses: $player1Misses
  Sunk Opponent Ships: $player1SunkShips
  Remaining Ships: $player1RemainingShips
  Remaining Ship Cells: $player1RemainingCells
Player 2:
  Total Shots: $player2Shots
  Hits: $player2Hits
  Misses: $player2Misses
  Sunk Opponent Ships: $player2SunkShips
  Remaining Ships: $player2RemainingShips
  Remaining Ship Cells: $player2RemainingCells
---------------
''';
    file.writeAsStringSync(content, mode: FileMode.append);
  }
}

class Player {
  String name;
  Board board;
  int shots = 0;
  int hits = 0;
  int misses = 0;
  int sunkShips = 0;

  Player(this.name) : board = Board();

  void placeShips() {
    board.placeShipsRandomly();
  }

  (int, int)? getShotInput() {
    while (true) {
      try {
        stdout.write('$name, введите координаты (например, A5): ');
        String input = stdin.readLineSync()?.trim().toUpperCase() ?? '';
        if (input.length < 2) throw FormatException('Слишком короткий ввод');
        int col = input.codeUnitAt(0) - 'A'.codeUnitAt(0);
        int row = int.parse(input.substring(1)) - 1;
        if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
          return (row, col);
        }
        print('Координаты вне диапазона. Попробуйте снова.');
      } catch (e) {
        print('Неверный ввод. Пожалуйста, введите в формате A5.');
      }
    }
  }
}

class AIPlayer extends Player {
  List<(int, int)> potentialTargets = [];
  List<(int, int)> hitStack = [];
  Random rand = Random();
  Set<(int, int)> attacked = {};

  AIPlayer() : super('ИИ');

  @override
  (int, int) getShotInput() {
    (int, int) target;
    if (hitStack.isNotEmpty) {
      target = _getAdjacentTarget();
    } else {
      target = _getRandomTarget();
    }
    print('ИИ стреляет в ${String.fromCharCode('A'.codeUnitAt(0) + target.$2)}${target.$1 + 1}');
    return target;
  }

  (int, int) _getRandomTarget() {
    while (true) {
      int row = rand.nextInt(boardSize);
      int col = rand.nextInt(boardSize);
      if (!attacked.contains((row, col)) && board.grid[row][col] != CellState.marked) {
        return (row, col);
      }
    }
  }

  (int, int) _getAdjacentTarget() {
    while (hitStack.isNotEmpty) {
      var (row, col) = hitStack.last;
      List<(int, int)> directions = [(0,1), (0,-1), (1,0), (-1,0)];
      directions.shuffle();
      for (var (dr, dc) in directions) {
        int nr = row + dr;
        int nc = col + dc;
        if (nr >= 0 && nr < boardSize && nc >= 0 && nc < boardSize &&
            !attacked.contains((nr, nc)) && board.grid[nr][nc] != CellState.marked) {
          return (nr, nc);
        }
      }
      hitStack.removeLast();
    }
    return _getRandomTarget();
  }

  void feedback(int row, int col, AttackResult result) {
    attacked.add((row, col));
    if (result == AttackResult.hit || result == AttackResult.sunk) {
      hitStack.add((row, col));
      if (result == AttackResult.sunk) {
        hitStack.removeLast();
      }
    }
  }
}

void main() {
  print('Добро пожаловать в Морской бой!');
  bool playAgain = true;
  int player1Wins = 0;
  int player2Wins = 0;
  int gameNumber = 1;

  while (playAgain) {
    GameStats stats = GameStats();
    print('Выберите режим: 1 - против ИИ, 2 - против игрока');
    String modeInput = stdin.readLineSync()!.trim();
    bool vsAI = modeInput == '1';

    Player player1 = Player('Игрок 1');
    Player player2 = vsAI ? AIPlayer() : Player('Игрок 2');

    player1.placeShips();
    player2.placeShips();

    Player currentPlayer = player1;
    Board targetBoard = player2.board;

    while (!player1.board.allShipsSunk() && !player2.board.allShipsSunk()) {
      print('\n--- Ход ${currentPlayer.name} ---');
      print('Ваша доска:');
      currentPlayer.board.display(hideShips: false);
      print('Доска противника:');
      targetBoard.display(hideShips: true);

      var shot = currentPlayer.getShotInput();
      if (shot == null) {
        print('Неверный ввод. Попробуйте снова.');
        continue;
      }
      currentPlayer.shots++;
      if (currentPlayer == player1) {
        stats.player1Shots++;
      } else {
        stats.player2Shots++;
      }

      AttackResult result = targetBoard.attack(shot.$1, shot.$2);

      String message;
      switch (result) {
        case AttackResult.hit:
          message = 'Попадание!';
          currentPlayer.hits++;
          if (currentPlayer == player1) {
            stats.player1Hits++;
          } else {
            stats.player2Hits++;
          }
          break;
        case AttackResult.miss:
          message = 'Промах!';
          currentPlayer.misses++;
          if (currentPlayer == player1) {
            stats.player1Misses++;
          } else {
            stats.player2Misses++;
          }
          break;
        case AttackResult.sunk:
          message = 'Корабль потоплен!';
          currentPlayer.hits++;
          currentPlayer.sunkShips++;
          if (currentPlayer == player1) {
            stats.player1Hits++;
            stats.player1SunkShips++;
          } else {
            stats.player2Hits++;
            stats.player2SunkShips++;
          }
          break;
        case AttackResult.alreadyAttacked:
          message = 'Уже стреляли сюда. Попробуйте снова.';
          continue;
        case AttackResult.invalid:
          message = 'Неверные координаты. Попробуйте снова.';
          continue;
      }
      print(message);

      if (currentPlayer is AIPlayer) {
        (currentPlayer as AIPlayer).feedback(shot.$1, shot.$2, result);
      }

      if (targetBoard.allShipsSunk()) {
        stats.winner = currentPlayer.name;
        stats.player1RemainingShips = player1.board.getRemainingShips();
        stats.player2RemainingShips = player2.board.getRemainingShips();
        stats.player1RemainingCells = player1.board.getRemainingShipCells();
        stats.player2RemainingCells = player2.board.getRemainingShipCells();
        print('\n$currentPlayer.name победил, уничтожив все корабли противника!');
        print('Игрок 1 потерял ${10 - stats.player1RemainingShips} кораблей, осталось ${stats.player1RemainingShips}/10 кораблей, ${stats.player1RemainingCells}/20 клеток.');
        print('${vsAI ? 'ИИ' : 'Игрок 2'} потерял ${10 - stats.player2RemainingShips} кораблей, осталось ${stats.player2RemainingShips}/10 кораблей, ${stats.player2RemainingCells}/20 клеток.');
        if (currentPlayer == player1) player1Wins++;
        else player2Wins++;
        stats.saveToFile('game_stats', 'battleship_stats_game_$gameNumber.txt');
        gameNumber++;
        break;
      }

      currentPlayer = (currentPlayer == player1) ? player2 : player1;
      targetBoard = (targetBoard == player2.board) ? player1.board : player2.board;
    }

    print('\nСтатистика игры:');
    print('Игрок 1: Выстрелов: ${player1.shots}, Попаданий: ${player1.hits}, Промахов: ${player1.misses}, Потоплено кораблей противника: ${player1.sunkShips}, Точность: ${(player1.shots > 0 ? player1.hits / player1.shots * 100 : 0).toStringAsFixed(2)}%');
    print('${vsAI ? 'ИИ' : 'Игрок 2'}: Выстрелов: ${player2.shots}, Попаданий: ${player2.hits}, Промахов: ${player2.misses}, Потоплено кораблей противника: ${player2.sunkShips}, Точность: ${(player2.shots > 0 ? player2.hits / player2.shots * 100 : 0).toStringAsFixed(2)}%');
    print('Всего побед: Игрок 1: $player1Wins, ${vsAI ? 'ИИ' : 'Игрок 2'}: $player2Wins');

    print('Сыграть еще раз? (д/н)');
    playAgain = stdin.readLineSync()!.trim().toLowerCase() == 'д';
  }
  print('Спасибо за игру!');
}