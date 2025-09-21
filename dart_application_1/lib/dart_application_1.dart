import 'dart:io';
import 'dart:convert';
import 'dart:math';

class TicTacToe {
  late List<List<String>> board;
  late int size;
  String userMark = 'X';
  String botMark = 'O';
  String currentPlayer = 'X';
  String gameMode = 'human';
  Random random = Random();

  TicTacToe(int boardSize) {
    size = boardSize;
    board = List.generate(size, (i) => List.generate(size, (j) => ' '));
  }

  void chooseMark(String mark) {
    userMark = mark.toUpperCase();
    botMark = (mark.toUpperCase() == 'O') ? 'X' : 'O';
    currentPlayer = userMark;
  }

  void displayBoard() {
    print('\n${'=' * (size * 4 + 1)}');
    for (int i = 0; i < size; i++) {
      String row = '|';
      for (int j = 0; j < size; j++) {
        row += ' ${board[i][j]} |';
      }
      print(row);
      if (i < size - 1) {
        print('|' + '---|' * size);
      }
    }
    print('=' * (size * 4 + 1));
  }

  bool checkWin(String mark) {
    for (int i = 0; i < size; i++) {
      if (board[i].every((cell) => cell == mark)) {
        return true;
      }
    }

    for (int j = 0; j < size; j++) {
      bool columnWin = true;
      for (int i = 0; i < size; i++) {
        if (board[i][j] != mark) {
          columnWin = false;
          break;
        }
      }
      if (columnWin) return true;
    }

    bool mainDiagonalWin = true;
    for (int i = 0; i < size; i++) {
      if (board[i][i] != mark) {
        mainDiagonalWin = false;
        break;
      }
    }
    if (mainDiagonalWin) return true;

    bool antiDiagonalWin = true;
    for (int i = 0; i < size; i++) {
      if (board[i][size - 1 - i] != mark) {
        antiDiagonalWin = false;
        break;
      }
    }
    if (antiDiagonalWin) return true;

    return false;
  }

  bool checkDraw() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == ' ') {
          return false;
        }
      }
    }
    return true;
  }

  bool makeMove(int row, int col) {
    if (row < 0 ||
        row >= size ||
        col < 0 ||
        col >= size ||
        board[row][col] != ' ') {
      return false;
    }
    board[row][col] = currentPlayer;
    return true;
  }

  void switchPlayer() {
    currentPlayer = currentPlayer == userMark ? botMark : userMark;
  }

  void randomizeFirstPlayer() {
    currentPlayer = random.nextBool() ? userMark : botMark;
  }

  List<int> getAIMove() {
    List<List<int>> availableMoves = [];

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == ' ') {
          availableMoves.add([i, j]);
        }
      }
    }

    for (var move in availableMoves) {
      int i = move[0], j = move[1];
      board[i][j] = botMark;
      if (checkWin(botMark)) {
        board[i][j] = ' ';
        return [i, j];
      }
      board[i][j] = ' ';
    }

    for (var move in availableMoves) {
      int i = move[0], j = move[1];
      board[i][j] = userMark;
      if (checkWin(userMark)) {
        board[i][j] = ' ';
        return [i, j];
      }
      board[i][j] = ' ';
    }

    int center = size ~/ 2;
    if (board[center][center] == ' ') {
      return [center, center];
    }

    if (availableMoves.isNotEmpty) {
      return availableMoves[random.nextInt(availableMoves.length)];
    }

    return [0, 0];
  }

  void resetGame() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        board[i][j] = ' ';
      }
    }
    randomizeFirstPlayer();
  }
}

void runGame() {
  stdout.encoding = utf8;

  print('🎮 Добро пожаловать в игру "Крестики-нолики"! 🎮');

  TicTacToe? game;
  String gameMode = 'human';
  String mark = 'X';

  while (true) {
    stdout.write('\x1B[2J\x1B[H');
    print('\n' + '=' * 50);
    print('ГЛАВНОЕ МЕНЮ');
    print('Текущий режим: ${gameMode == 'human' ? 'Человек против человека' : 'Человек против ИИ'}');
    print('Текущий символ: $mark');
    print('=' * 50);
    print('1. Начать новую игру');
    print('2. Выбрать режим игры');
    print('3. Выбрать символ (X или O)');
    print('0. Выход');

    stdout.write('\nВыберите действие: ');
    String? choice = stdin.readLineSync();

    switch (choice?.trim()) {
      case '1':
        if (game == null) {
          int? size = getBoardSize();
          if (size != null) {
            game = TicTacToe(size);
            game.gameMode = gameMode;
            game.chooseMark(mark);
            playGame(game);
          }
        } else {
          game.resetGame();
          game.gameMode = gameMode;
          game.chooseMark(mark);
          playGame(game);
        }
        break;
      case '2':
        gameMode = selectGameMode();
        print(
          'Режим игры изменен на: ${gameMode == 'human' ? 'Человек против человека' : 'Человек против ИИ'}',
        );
        if (game != null) {
          game.gameMode = gameMode;
        }
        break;
      case '3':
        mark = selectMark();
        if (game != null) {
          game.chooseMark(mark);
        }
        print('Вы выбрали символ: $mark');
        break;
      case '0':
        print('Спасибо за игру! До свидания! 👋');
        return;
      default:
        print('Неверный выбор. Попробуйте снова.');
    }
  }
}

int? getBoardSize() {
  while (true) {
    stdout.write('\x1B[2J\x1B[H');
    stdout.write('\nВведите размер игрового поля (от 3 до 10): ');
    String? input = stdin.readLineSync();

    if (input == null || input.trim().isEmpty) {
      print('Пожалуйста, введите число.');
      continue;
    }

    try {
      int size = int.parse(input.trim());
      if (size >= 3 && size <= 10) {
        return size;
      } else {
        print('Размер поля должен быть от 3 до 10.');
      }
    } catch (e) {
      print('Пожалуйста, введите корректное число.');
    }
  }
}

String selectGameMode() {
  while (true) {
    stdout.write('\x1B[2J\x1B[H');
    print('\nВыберите режим игры:');
    print('1. Человек против человека');
    print('2. Человек против ИИ');

    stdout.write('Введите номер режима: ');
    String? choice = stdin.readLineSync();

    switch (choice?.trim()) {
      case '1':
        return 'human';
      case '2':
        return 'ai';
      default:
        print('Неверный выбор. Попробуйте снова.');
    }
  }
}

String selectMark() {
  while (true) {
    stdout.write('\x1B[2J\x1B[H');
    print('\nВыберите ваш символ (X или O): ');
    String? choice = stdin.readLineSync();

    if (choice != null && (choice.trim().toUpperCase() == 'X' || choice.trim().toUpperCase() == 'O')) {
      return choice.trim().toUpperCase();
    }
    print('Пожалуйста, выберите X или O.');
  }
}

void playGame(TicTacToe game) {
  stdout.write('\x1B[2J\x1B[H');
  print('\n🎯 Начинаем новую игру!');
  print('Размер поля: ${game.size}x${game.size}');
  print(
    'Режим: ${game.gameMode == 'human' ? 'Человек против человека' : 'Человек против ИИ'}',
  );
  print('Первый ход делает игрок: ${game.currentPlayer}');

  while (true) {
    stdout.write('\x1B[2J\x1B[H');
    game.displayBoard();

    print('\nХод игрока: ${game.currentPlayer}');

    if (game.gameMode == 'ai' && game.currentPlayer == game.botMark) {
      print('ИИ думает...');
      List<int> aiMove = game.getAIMove();
      if (game.makeMove(aiMove[0], aiMove[1])) {
        print('ИИ сделал ход: ${aiMove[0] + 1}, ${aiMove[1] + 1}');
      }
    } else {
      List<int>? move = getPlayerMove(game.size);
      if (move != null) {
        if (!game.makeMove(move[0], move[1])) {
          print('Неверный ход! Попробуйте снова.');
          continue;
        } else {
          print('Ход принят!');
        }
      } else {
        print('Неверный ввод! Попробуйте снова.');
        continue;
      }
    }

    stdout.write('\x1B[2J\x1B[H');
    game.displayBoard();

    if (game.checkWin(game.currentPlayer)) {
      print('\n🎉 Поздравляем! Игрок ${game.currentPlayer} победил! 🎉');
      break;
    }

    if (game.checkDraw()) {
      print('\n🤝 Ничья! Игра завершена вничью! 🤝');
      break;
    }

    game.switchPlayer();
  }

  print('\n' + '=' * 30);
  stdout.write('Хотите сыграть еще раз? (y/n): ');
  String? playAgain = stdin.readLineSync();

  if (playAgain?.toLowerCase().trim() == 'y' ||
      playAgain?.toLowerCase().trim() == 'yes') {
    game.resetGame();
    game.gameMode = game.gameMode;
    playGame(game);
  }
}

List<int>? getPlayerMove(int boardSize) {
  while (true) {
    stdout.write('Введите координаты хода (строка столбец, например: 1 2): ');
    String? input = stdin.readLineSync();

    if (input == null || input.trim().isEmpty) {
      print('Пожалуйста, введите координаты.');
      continue;
    }

    List<String> coords = input.trim().split(' ');
    if (coords.length != 2) {
      print('Введите две координаты через пробел.');
      continue;
    }

    try {
      int row = int.parse(coords[0]) - 1;
      int col = int.parse(coords[1]) - 1;

      if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
        return [row, col];
      } else {
        print('Координаты должны быть от 1 до $boardSize.');
      }
    } catch (e) {
      print('Пожалуйста, введите корректные числа.');
    }
  }
}

