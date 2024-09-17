#include <stdio.h>

/*
int main(void) { // 1.1
  printf("C uses escape sequences for a variety of purposes.\n");
  printf("Some common ones are:\n");
  printf("     to print \", use \\\"\n");
  printf("     to print \\, use \\\\\n");
  printf("     to jump to a new line, use \\n\n");
  return 0;
}

int main(void) { // 1.2
  double convRate, convAmount, resAmount;
  printf("Enter the conversion rate: ");
  scanf("%lf", &convRate);
  printf("Enter the amount to be converted (in foreign currency): ");
  scanf("%lf", &convAmount);
  resAmount = convRate * convAmount;
  printf("The amount in Canadian Dollars is:");
  printf(" %.2lf", resAmount);
  return 0;
}
*/

int main(void) {  // 1.3
  int denNum, tempNum;
  int dig1, dig2, dig3, dig4;
  // char biNum[4] = "0000"; // replace with four var
  printf("Enter number to convert to base 2:");
  scanf("%d", &denNum);
  tempNum = denNum;
  /*
  for (int i = 3; i >= 0; i -= 1) { // remove the loops
    biNum[i] = (char)(tempNum % 2);
    tempNum /= 2;
  }
  */
  dig4 = tempNum % 2;
  tempNum /= 2;
  dig3 = tempNum % 2;
  tempNum /= 2;
  dig2 = tempNum % 2;
  tempNum /= 2;
  dig1 = tempNum % 2;
  printf("The four digits of that number are as follows:\n");
  printf("Most significant digit:%d\n", dig1);
  printf("Next digit:%d\n", dig2);
  printf("Next digit:%d\n", dig3);
  printf("Least significant digit:%d\n", dig4);

  /*
   printf("The four digits of that number are as follows:\n");
   printf("Most significant digit:%d\n", (int)(biNum[0]));
   printf("Next digit:%d\n", (int)(biNum[1]));
   printf("Next digit:%d\n", (int)(biNum[2]));
   printf("Least significant digit:%d\n", (int)(biNum[3]));
   */
  return 0;
}
