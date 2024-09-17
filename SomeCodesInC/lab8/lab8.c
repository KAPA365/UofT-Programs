/**
 * @file reversi.c
 * @author <jixu5>
 * @brief This file is used for APS105 Lab 8. 2023W version
 * @date 2023-04-01
 *
 */

/*
#if !defined(TESTER_P1) && !defined(TESTER_P2)
#include "reversi.h"
#endif
*/

#include <stdbool.h>
#include <stdio.h>
#include <string.h>

void printBoard(char board[][26], int n) {  // lab7
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

bool positionInBounds(int n, int row, int col) {  // lab7
  if (row >= n || col >= n || row < 0 || col < 0) {
    return false;
  }
  return true;
}

void boardInit(char board[][26], int n) {  // lab7
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

int calculateScoreInDirection(char board[][26], int n, int row, int col,
                              char colour, int deltaRow, int deltaCol) {
  int newRow = row + deltaRow;
  int newCol = col + deltaCol;
  char newColour;
  if (colour == 'W') {
    newColour = 'B';
  } else {
    newColour = 'W';
  }
  int i = 1;
  while (positionInBounds(n, newRow + deltaRow, newCol + deltaCol) &&
         board[newRow][newCol] == newColour) {
    if (board[newRow + deltaRow][newCol + deltaCol] == colour) {
      return i;
    }
    i++;
    newRow += deltaRow;
    newCol += deltaCol;
  }
  return 0;
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

void scoreInit(int score[][26], int n) {
  for (int row = 0; row < n; row++) {
    for (int col = 0; col < n; col++) {
      score[row][col] = 0;
    }
  }
}

void calculateScores(char board[][26], int n, char colour, int score[][26]) {
  int rowDir[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
  int colDir[8] = {-1, 0, 1, -1, 1, -1, 0, 1};
  for (int row = 0; row < n; row++) {
    for (int col = 0; col < n; col++) {
      if (board[row][col] == 'U') {
        for (int dir = 0; dir < 8; dir++) {
          if (checkLegalInDirection(board, n, row, col, colour, rowDir[dir],
                                    colDir[dir])) {
            score[row][col] += calculateScoreInDirection(
                board, n, row, col, colour, rowDir[dir], colDir[dir]);
          }
        }
      }
    }
  }
}

int isAvailableMoves(char board[][26], int n, char colour) {
  int rowDir[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
  int colDir[8] = {-1, 0, 1, -1, 1, -1, 0, 1};
  bool flag = false;
  for (int row = 0; row < n; row++) {
    for (int col = 0; col < n; col++) {
      for (int dir = 0; dir < 8; dir++) {
        if (board[row][col] == 'U' &&
            checkLegalInDirection(board, n, row, col, colour, rowDir[dir],
                                  colDir[dir])) {
          flag = true;
          break;
        }
      }
    }
  }
  return flag;
}

int gameMove(char board[][26], int n, int row, int col,
             char colour) {  // player
  if (!positionInBounds(n, row, col) || board[row][col] != 'U') {
    return -1;
  }
  int rowDir[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
  int colDir[8] = {-1, 0, 1, -1, 1, -1, 0, 1};
  bool flag = false;
  for (int dir = 0; dir < 8; dir++) {
    if (checkLegalInDirection(board, n, row, col, colour, rowDir[dir],
                              colDir[dir])) {
      int newRow = row + rowDir[dir];
      int newCol = col + colDir[dir];

      while (board[newRow][newCol] != colour) {
        board[newRow][newCol] = colour;
        newRow += rowDir[dir];
        newCol += colDir[dir];
      }
      flag = true;
    }
  }
  if (flag) {
    board[row][col] = colour;
    return 1;
  }
  return -1;
}

int makeMove(char board[][26], int n, char turn, int *row, int *col) {  // comp
  int score[26][26];
  scoreInit(score, n);
  calculateScores(board, n, turn, score);
  int bestScore = -1;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (score[i][j] > bestScore) {
        bestScore = score[i][j];
        *row = i;
        *col = j;
      }
    }
  }
  if (bestScore == 0) {
    return 0;
  }
  int rowDir[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
  int colDir[8] = {-1, 0, 1, -1, 1, -1, 0, 1};
  for (int dir = 0; dir < 8; dir++) {
    if (checkLegalInDirection(board, n, *row, *col, turn, rowDir[dir],
                              colDir[dir])) {
      int newRow = *row + rowDir[dir];
      int newCol = *col + colDir[dir];
      while (board[newRow][newCol] != turn) {
        board[newRow][newCol] = turn;
        newRow += rowDir[dir];
        newCol += colDir[dir];
      }
    }
  }
  board[*row][*col] = turn;
  return 1;
}

// #ifndef TESTER_P2

int main(void) {
  int dim;
  printf("Enter the board dimension: ");
  scanf("%d", &dim);
  char compColour;
  printf("Computer plays (B/W): ");
  scanf(" %c", &compColour);
  char board[26][26];
  boardInit(board, dim);
  printBoard(board, dim);
  char userColour;
  int userMove, compMove;
  bool uMoves = true, cMoves = true;
  int game = 1;
  char userIn[2];
  if (compColour == 'W') {
    userColour = 'B';
    if (isAvailableMoves(board, dim, userColour)) {
      printf("Enter move for colour %c (RowCol): ", userColour);
      scanf("%s", userIn);
      userMove = gameMove(board, dim, (int)userIn[0] - 97, (int)userIn[1] - 97,
                          userColour);
      if (userMove == -1) {
        printf("Invalid move.\n");
        printf("%c player wins.\n", compColour);
        game = -1;
      } else {
        printBoard(board, dim);
      }
    } else {
      if (cMoves) {
        printf("%c player has no valid move.\n", userColour);
      }
      uMoves = false;
    }
  } else {
    userColour = 'W';
  }
  while (game == 1) {
    if (cMoves) {
      int row = 0, col = 0;
      compMove = makeMove(board, dim, compColour, &row, &col);
      if (compMove == 0) {
        if (uMoves) {
          printf("%c player has no valid move.\n", compColour);
        }
        cMoves = false;
      } else {
        printf("Computer places %c at %c%c.\n", compColour, row + 97, col + 97);
        printBoard(board, dim);
      }
    }
    if (uMoves) {
      if (isAvailableMoves(board, dim, userColour)) {
        printf("Enter move for colour %c (RowCol): ", userColour);
        scanf("%s", userIn);
        userMove = gameMove(board, dim, (int)userIn[0] - 97,
                            (int)userIn[1] - 97, userColour);
        if (userMove == -1) {
          printf("Invalid move.\n");
          printf("%c player wins.\n", compColour);
          game = -1;
        } else {
          printBoard(board, dim);
        }
      } else {
        if (cMoves) {
          printf("%c player has no valid move.\n", userColour);
        }
        uMoves = false;
      }
    }
    if (!cMoves && !uMoves) {
      game = 0;
    }
  }
  if (game == 0) {
    int wCount = 0, bCount = 0;
    for (int j = 0; j < dim; j++) {
      for (int i = 0; i < dim; i++) {
        if (board[i][j] == 'W') {
          wCount++;
        } else {
          bCount++;
        }
      }
    }
    if (wCount > bCount) {
      printf("W player wins.");
    } else if (wCount < bCount) {
      printf("B player wins.");
    } else {
      printf("Draw!");
    }
  }
  return 0;
}

// #endif
