#include <math.h>
#include <stdbool.h>
#include <stdio.h>
/*
int getAscendingOrderedDigits(int num);  // 4.1

int reverseNumber(int num) {
  int result = 0;
  for (int i = 0; i <= 3; i++) {
    result += ((num / (int)(pow(10, i))) % 10) * (int)(pow(10, 3 - i));
  }
  return result;
}

int getNumber(void) {
  int num;
  while (1) {
    printf("Enter a number (-1 to stop):");
    scanf("%d", &num);
    if (num != -1) {
      if (num > 9999) {
        printf("Error: the number is too large.\n");
        continue;
      } else if (num < 1000) {
        printf("Error: the number is too small.\n");
        continue;
      } else {
        break;
      }
    } else {
      break;
    }
  }
  return num;
}

int main(void) {
  while (1) {
    int rawNum = getNumber();
    if (rawNum == -1) {
      break;
    } else {
      int count = 0;
      int resNum = rawNum;
      while (1) {
        printf("Number %d: %d\n", count + 1, resNum);
        if (resNum == 6174) {
          printf("Kaprekar's Constant was reached in %d iteration(s).\n",
                 count);
          break;
        }
        int aNum = getAscendingOrderedDigits(resNum);
        int dNum = reverseNumber(aNum);
        resNum = dNum - aNum;
        count++;
      }
    }
  }
  return 0;
}
*/


bool isStar(int plot[], int x, int y, int size) { //4.2
  int yExpect = 0;
  bool draw = false;
  for (int i = 0; i <= size; i++) {
    yExpect += plot[i] * (int)(pow(x, i));
  }
  if (yExpect == y) {
    draw = true;
  }
  return draw;
}

void plotGrid(int plotData[], int sz) {
  for (int j = 10; j >= -10; j--) {
    for (int i = -10; i <= 10; i++) {
      if (isStar(plotData, i, j, sz)) {
        printf(" * ");
      } else if (i == 0) {
        printf(" | ");
      } else if (j == 0) {
        printf(" - ");
      } else {
        printf("   ");
      }
    }
    printf("\n");
  }
}

int main(void) {
  int order = 0;
  int plotData[4];
  while (1) {
    printf("Enter the order of the function:");
    scanf("%d", &order);
    if (order == -1) {
      return 0;
    }
    while (order > 3 || order < 0) {
      printf("The order must be between [0, 3].\n");
      printf("Enter the order of the function:");
      scanf("%d", &order);
      if (order == -1) {
        return 0;
      }
    }
    for (int i = 0; i <= order; i++) {
      int temp;
      printf("Enter coefficient of x^%d:", i);
      scanf("%d", &temp);
      plotData[i] = temp;
    }
    plotGrid(plotData, order);
  }
  return 0;
}
