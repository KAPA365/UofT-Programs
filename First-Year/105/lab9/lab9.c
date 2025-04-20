#include "stdbool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

/* DO NOT EDIT THE LINES BELOW */
#define STRING_MAX 1024

typedef struct node {
  char *name;
  int lines;
  int runtime;
  int memory_usage;

  struct node *next;
} Node;

typedef struct linked_list {
  Node *head;
} LinkedList;

void readInputString(char *, int);
void readInputNumber(int *);
void readInputChar(char *);

LinkedList *newList();
char getCommand();

void handleInsert(LinkedList *);
void handleDelete(LinkedList *);
void handleSearch(LinkedList *);
void handlePrint(LinkedList *);
void handleQuit(LinkedList *);

int main() {
  LinkedList *list = newList();
  char command = '\0';

  printf("Experimental database entry\n");

  while (command != 'Q') {
    command = getCommand();

    switch (command) {
      case 'I':
        handleInsert(list);
        break;
      case 'D':
        handleDelete(list);
        break;
      case 'S':
        handleSearch(list);
        break;
      case 'P':
        handlePrint(list);
        break;
      case 'Q':
        handleQuit(list);
        break;
    }
  }

  free(list);
  return 0;
}
/* DO NOT EDIT THE LINES ABOVE */

void handleInsert(LinkedList *list) {
  // place your code to handle the insert command here
  int nameLen, newLinesCount, newRunTime, newMemUsage;
  printf("\nNumber of characters in file name: ");
  readInputNumber(&nameLen);
  char newFileName[STRING_MAX];
  printf("File name: ");
  readInputString(newFileName, nameLen + 1);
  printf("Number of lines in CSV file: ");
  readInputNumber(&newLinesCount);
  printf("Experiment runtime (ms): ");
  readInputNumber(&newRunTime);
  printf("Experiment memory usage (B): ");
  readInputNumber(&newMemUsage);
  Node *newNodePtr = (Node *)malloc(sizeof(Node));
  newNodePtr->name = (char *)malloc((nameLen + 1) * sizeof(char));
  strcpy(newNodePtr->name, newFileName);
  newNodePtr->lines = newLinesCount;
  newNodePtr->runtime = newRunTime;
  newNodePtr->memory_usage = newMemUsage;
  Node *currentPtr = list->head;
  Node *lastPtr = NULL;
  while (currentPtr != NULL) {
    int compRslt = strcmp(newFileName, currentPtr->name);
    if (compRslt == 0) {
      printf("\nAn entry with that file name already exists.\n");
      free(newNodePtr->name);
      free(newNodePtr);
      return;
    } else if (compRslt < 0) {
      newNodePtr->next = currentPtr;
      if (lastPtr == NULL) {
        list->head = newNodePtr;
      } else {
        lastPtr->next = newNodePtr;
      }
      return;
    }
    lastPtr = currentPtr;
    currentPtr = currentPtr->next;
  }
  if (currentPtr == NULL) {
    newNodePtr->next = NULL;
    if (lastPtr == NULL) {
      list->head = newNodePtr;
    } else {
      lastPtr->next = newNodePtr;
    }
  }
}

void handleDelete(LinkedList *list) {
  // place your code to handle the delete command here
  char newFileName[10];
  printf("\nEnter file name to delete: ");
  readInputString(newFileName, 10);
  Node *currentPtr = list->head;
  Node *lastPtr = NULL;
  bool found = false;
  while (currentPtr != NULL) {
    int compRslt = strcmp(newFileName, currentPtr->name);
    if (compRslt == 0) {
      found = true;
      printf("Deleting entry for CSV file <%s>\n", newFileName);
      if (lastPtr == NULL) {
        list->head = currentPtr->next;
      } else {
        lastPtr->next = currentPtr->next;
      }
      free(currentPtr->name);
      free(currentPtr);
      break;
    }
    lastPtr = currentPtr;
    currentPtr = currentPtr->next;
  }
  if (found == false) {
    printf("An entry for file <%s> does not exist.\n", newFileName);
  }
}

void handleSearch(LinkedList *list) {
  // place your code to handle the search command here
  char newFileName[10];
  printf("\nEnter file name to find: ");
  readInputString(newFileName, 10);
  Node *currentPtr = list->head;
  bool found = false;
  while (currentPtr != NULL) {
    int compRslt = strcmp(newFileName, currentPtr->name);
    if (compRslt == 0) {
      found = true;
      printf("File <%s>\n", currentPtr->name);
      printf("Lines: %d\n", currentPtr->lines);
      printf("Runtime (ms): %d\n", currentPtr->runtime);
      printf("Memory usage (B): %d\n", currentPtr->memory_usage);
      double timeflt = currentPtr->runtime * 1.0;
      double lineflt = currentPtr->lines * 1.0;
      printf("Throughput: %.2lf\n", lineflt / timeflt * 1000);
      break;
    }
    currentPtr = currentPtr->next;
  }
  if (found == false) {
    printf("An entry for file <%s> does not exist.\n", newFileName);
  }
}

void handlePrint(LinkedList *list) {
  // place your code to handle the print command here
  Node *currentPtr = list->head;
  bool isEmpty = true;
  printf("\nData entries:\n");
  while (currentPtr != NULL) {
    printf("File <%s>\n", currentPtr->name);
    printf("Lines: %d\n", currentPtr->lines);
    printf("Runtime (ms): %d\n", currentPtr->runtime);
    printf("Memory usage (B): %d\n", currentPtr->memory_usage);
    double timeflt = currentPtr->runtime * 1.0;
    double lineflt = currentPtr->lines * 1.0;
    printf("Throughput: %.2lf\n", lineflt / timeflt * 1000);
    currentPtr = currentPtr->next;
    isEmpty = false;
  }
  if (isEmpty) {
    printf("There are no data entries.\n");
  }
}

void handleQuit(LinkedList *list) {
  // place your code to handle the quit command here
  Node *currentPtr = list->head;
  Node *tempPtr;
  while (currentPtr != NULL) {
    printf("Deleting entry for CSV file <%s>\n", currentPtr->name);
    tempPtr = currentPtr->next;
    free(currentPtr->name);
    free(currentPtr);
    currentPtr = tempPtr;
  }
  list->head = NULL;
}

/* DO NOT EDIT THE LINES BELOW */
void readInputString(char *str, int length) {
  int i = 0;
  char c;

  while (i < length && (c = getchar()) != '\n') {
    str[i++] = c;
  }
  str[i] = '\0';
}

void readInputNumber(int *number) {
  char buf[STRING_MAX];
  readInputString(buf, STRING_MAX);
  *number = (int)strtol(buf, (char **)NULL, 10);
}

void readInputChar(char *character) {
  char buf[2];
  readInputString(buf, 3);
  *character = buf[0];
}

LinkedList *newList() {
  LinkedList *list = (LinkedList *)malloc(sizeof(LinkedList));
  list->head = NULL;
  return list;
}

char getCommand() {
  char command;

  printf("\nSupported commands are:\n");
  printf("  I - Insert\n");
  printf("  D - Delete\n");
  printf("  S - Search\n");
  printf("  P - Print\n");
  printf("  Q - Quit\n");

  printf("\nPlease select a command: ");
  readInputChar(&command);

  while (command != 'I' && command != 'D' && command != 'S' && command != 'P' &&
         command != 'Q') {
    printf("Invalid command <%c>, please select a command: ", command);
    readInputChar(&command);
  }

  return command;
}
/* DO NOT EDIT THE LINES ABOVE */
