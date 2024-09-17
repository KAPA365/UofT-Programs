#include <iostream>
using namespace std;
int foo(int a) {
  a += 1;
  return a;
}
int bar(int* a) {
  *a += 1;
  return *a;
}
int zoo(int& a) {
  a += 1;
  return a;
}
void ml() {
  int x = 0;
  int y = 0;
  int* p = &x;
  int* q = &y;
  *p += foo(x) + zoo(y);
  *q += foo(y) + zoo(x);
  cout << "Check point 1:" << endl;
  cout << "x: " << x << endl;
  cout << "y: " << y << endl;
}
void m2() {
  int x = 0;
  int y = 0;
  int* p = &x;
  int* q = &y;
  x += foo(*q) + bar(p);
  y += foo(*p) + bar(q);
  cout << "Check point 2:" << endl;
  cout << "x: " << x << endl;
  cout << "y: " << y << endl;
}

int main() {
  m2();
  return 0;
}