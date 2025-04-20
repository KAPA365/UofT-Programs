#include <stdbool.h>
#include <stdio.h>
#include <string.h>

void printBoard(char board[][26], int n) {
  printf("  ");
  for (int i = 0; i < n; i++) {
    printf("%c", i + 97);
  }
  printf("\n");
  for (int row = 0; row < n; row++) {
    printf("%c ", row + 97);
    for (int col = 0; col < n; col++) {
      printf("%c", board[row][col]);
    }
    printf("\n");
  }
}

bool positionInBounds(int n, int row, int col) {
  if (row >= n || col >= n) {
    return false;
  }
  return true;
}

void boardInit(char board[][26], int n) {
  for (int row = 0; row < n; row++) {
    for (int col = 0; col < n; col++) {
      if ((row == n / 2 - 1 && col == n / 2 - 1) ||
          (row == n / 2 && col == n / 2)) {
        board[row][col] = 'W';
      } else if ((row == n / 2 - 1 && col == n / 2) ||
                 (row == n / 2 && col == n / 2 - 1)) {
        board[row][col] = 'B';
      } else {
        board[row][col] = 'U';
      }
    }
  }
}

bool checkLegalInDirection(char board[][26], int n, int row, int col,
                           char colour, int deltaRow, int deltaCol) {
  int newRow = row + deltaRow;
  int newCol = col + deltaCol;
  char newColour;
  if (colour == 'W') {
    newColour = 'B';
  } else {
    newColour = 'W';
  }
  while (positionInBounds(n, newRow + deltaRow, newCol + deltaCol) &&
         board[newRow][newCol] == newColour) {
    if (board[newRow + deltaRow][newCol + deltaCol] == colour) {
      return true;
    }
    newRow += deltaRow;
    newCol += deltaCol;
  }
  return false;
}

void checkAvailableMoves(char board[][26], int n, char colour) {
  int rowDir[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
  int colDir[8] = {-1, 0, 1, -1, 1, -1, 0, 1};
  for (int row = 0; row < n; row++) {
    for (int col = 0; col < n; col++) {
      if (board[row][col] == 'U') {
        for (int dir = 0; dir < 8; dir++) {
          if (checkLegalInDirection(board, n, row, col, colour, rowDir[dir],
                                    colDir[dir])) {
            printf("%c%c\n", row + 97, col + 97);
            break;
          }
        }
      }
    }
  }
}

bool gameMove(char board[][26], int n, int row, int col, char colour) {
  int rowDir[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
  int colDir[8] = {-1, 0, 1, -1, 1, -1, 0, 1};
  for (int dir = 0; dir < 8; dir++) {
    if (board[row][col] == 'U' &&
        checkLegalInDirection(board, n, row, col, colour, rowDir[dir],
                              colDir[dir])) {
      int i = 0;
      while (positionInBounds(n, i * rowDir[dir], i * colDir[dir])) {
        if (board[row + i * rowDir[dir]][col + i * colDir[dir]] != colour) {
          board[row + i * rowDir[dir]][col + i * colDir[dir]] = colour;
          i++;
        } else {
          break;
        }
      }
      return true;
    }
  }
  return false;
}

int main(void) {
  int dim;
  printf("Enter the board dimension: ");
  scanf("%d", &dim);
  char board[26][26];
  boardInit(board, dim);
  printBoard(board, dim);
  char userIn[3];
  printf("Enter board configuration:\n");
  while (1) {
    scanf("%s", userIn);
    if (strcmp(userIn, "!!!") != 0) {
      board[(int)(userIn[1]) - 97][(int)(userIn[2]) - 97] = userIn[0];
    } else {
      break;
    }
  }
  printBoard(board, dim);
  printf("Available moves for W:\n");
  checkAvailableMoves(board, dim, 'W');
  printf("Available moves for B:\n");
  checkAvailableMoves(board, dim, 'B');
  printf("Enter a move:\n");
  scanf("%s", userIn);
  if (gameMove(board, dim, (int)(userIn[1]) - 97, (int)(userIn[2]) - 97,
               userIn[0])) {
    printf("Valid move.\n");
  } else {
    printf("Invalid move.\n");
  }
  printBoard(board, dim);
  return 0;
}
