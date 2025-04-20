#include <stdio.h>
/*
#include <math.h>

int main(void) { // 2.1
  double oSide, aSide, hSide, angle;
  printf("Enter X: ");
  scanf("%lf", &aSide);
  printf("\nEnter Y: ");
  scanf("%lf", &oSide);
  printf("\n\n");
  hSide = pow((pow(aSide, 2) + pow(oSide, 2)), 0.5);
  angle = asin(oSide / hSide) * 180 / M_PI;
  printf("The Hypotenuse Length is: %.1lf\n", hSide);
  printf("The Angle Theta is %.1lf degrees\n", angle);
  return 0;
}
*/

/*
#include <string.h>

int main(void) {  // 2.2
  double xCord, yCord;
  char result[20] = "1234";
  printf("Enter the x-coordinate in floating point: ");
  scanf("%lf", &xCord);
  printf("\n");
  printf("Enter the y-coordinate in floating point: ");
  scanf("%lf", &yCord);
  if (xCord > 0) {
    if (yCord > 0) {
      strcpy(result, "in quadrant I.");
    } else if (yCord < 0) {
      strcpy(result, "in quadrant IV.");
    } else {
      strcpy(result, "on the x axis.");
    }
  } else if (xCord < 0) {
    if (yCord > 0) {
      strcpy(result, "in quadrant II.");
    } else if (yCord < 0) {
      strcpy(result, "in quadrant III.");
    } else {
      strcpy(result, "on the x axis.");
    }
  } else {
    if (yCord == 0) {
      strcpy(result, "at the origin.");
    } else {
      strcpy(result, "on the y axis.");
    }
  }
  printf("(%.2lf, %.2lf) is %s", xCord, yCord, result);
  return 0;
}
*/
