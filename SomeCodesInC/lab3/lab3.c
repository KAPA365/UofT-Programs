#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

/*
// 3.1
bool operandValid(int num1, int num2, int base) {
  bool valid = true;
  int tempNum1 = num1;
  int tempNum2 = num2;
  for (int i = 0; i <= 9; i++) {
    if ((tempNum1 % 10) > base - 1) {
      valid = false;
      break;
    }
    tempNum1 /= 10;
  }
  for (int i = 0; i <= 9; i++) {
    if ((tempNum2 % 10) > base - 1) {
      valid = false;
      break;
    }
    tempNum2 /= 10;
  }
  return valid;
}

int inToDen(int num, int base) {
  int retNum = 0;
  int tempNum = num;
  for (int i = 0; i <= 9; i++) {
    retNum += (tempNum % 10) * (int)(pow(base, i));
    tempNum /= 10;
    if (tempNum == 0) {
      break;
    }
  }
  return retNum;
}

int denToOut(int num, int base) {
  int tempNum = num;
  int retNum = 0;
  for (int i = 0; i <= 9; i++) {
    retNum += (tempNum % base) * (int)(pow(10, i));
    tempNum /= base;
    if (tempNum == 0) {
      break;
    }
  }

  return retNum;
}

int calc(int num1, int num2, char op[10]) {
  int retNum;
  if (strcmp(op, "+") == 0) {
    retNum = num1 + num2;
  } else if (strcmp(op, "-") == 0) {
    retNum = num1 - num2;
  } else if (strcmp(op, "*") == 0) {
    retNum = num1 * num2;
  } else if (strcmp(op, "/") == 0) {
    retNum = num1 / num2;
  }
  return retNum;
}
int main(void) {
  int baseIn, baseOut, data1, data2;
  char opIn[10] = "+";
  int ansData;
  while (1) {
    printf("Give input ($ to stop): ");
    scanf("%s", opIn);
    scanf("%d", &baseIn);
    scanf("%d", &data1);
    scanf("%d", &data2);
    scanf("%d", &baseOut);
    if (strcmp(opIn, "$") == 0) {
      break;
    }
    if (strcmp(opIn, "+") == 0 || strcmp(opIn, "-") == 0 ||
        strcmp(opIn, "*") == 0 || strcmp(opIn, "/") == 0) {
      if (2 <= baseIn && baseIn <= 10 && 2 <= baseOut && baseOut <= 10) {
        if (operandValid(data1, data2, baseIn)) {
          int den1 = inToDen(data1, baseIn);
          int den2 = inToDen(data2, baseIn);
          ansData = denToOut(calc(den1, den2, opIn), baseOut);
          printf("%d %s %d (base %d) = %d %s %d = %d (base %d)\n", data1, opIn,
                 data2, baseIn, den1, opIn, den2, ansData, baseOut);
        } else {
          printf("Invalid digits in operand\n");
          continue;
        }
      } else {
        printf("Invalid base\n");
        continue;
      }
    } else {
      printf("Invalid operator\n");
      continue;
    }
  }
  return 0;
}
*/

//3.2
int main(void){
  int r;
  printf("Enter the radius of the circle: ");
  scanf("%d", &r);
  for(int i=0; i<2*r+1; i++){
    for(int j=0; j<2*r+1; j++)
      if(abs(i-r)*abs(i-r)+ 
         abs(j-r)*abs(j-r)<=
         r*r) printf("o");
      else printf(".");
    printf("\n");
  }
  return 0;
}