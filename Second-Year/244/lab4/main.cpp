#include <cmath>
#include <cstdlib>
#include <iostream>
#include <sstream>

#include "Customer.h"
#include "QueueList.h"
#include "Register.h"
#include "RegisterList.h"

using namespace std;

// Function Declarations:
void update(string mode, double time);
// Set mode of the simulation
string getMode();

// Register
void parseRegisterAction(stringstream &lineStream, string mode);
void openRegister(
    stringstream &lineStream,
    string mode);  // register opens (it is upto customers to join)
void closeRegister(stringstream &lineStream,
                   string mode);  // register closes

// Customer
void addCustomer(stringstream &lineStream,
                 string mode);  // customer wants to join

// Helper functions
bool getInt(stringstream &lineStream, int &iValue);
bool getDouble(stringstream &lineStream, double &dValue);
bool foundMoreArgs(stringstream &lineStream);

// Global variables
RegisterList *registerList;  // holding the list of registers
QueueList *doneList;         // holding the list of customers served
QueueList *singleQueue;      // holding customers in a single virtual queue
double expTimeElapsed;  // time elapsed since the beginning of the simulation

// List of commands:
// To open a register
// register open <ID> <secPerItem> <setupTime> <timeElapsed>
// To close register
// register close <ID> <timeElapsed>
// To add a customer
// customer <items> <timeElapsed>

int main() {
  registerList = new RegisterList();
  doneList = new QueueList();
  singleQueue = new QueueList();
  expTimeElapsed = 0;

  // Set mode by the user
  string mode = getMode();
  string line;
  string command;

  cout << "> ";  // Prompt for input
  getline(cin, line);

  while (!cin.eof()) {
    stringstream lineStream(line);
    lineStream >> command;
    if (command == "register") {
      parseRegisterAction(lineStream, mode);
    } else if (command == "customer") {
      addCustomer(lineStream, mode);
    } else {
      cout << "Invalid operation" << endl;
    }
    cout << "> ";  // Prompt for input
    getline(cin, line);
  }
  /////////// eof
  int cnt = 0;
  double maxTime = 0, avgTime = 0, sdTime = 0, temp;
  Customer *thisPtr = doneList->get_head();  // get mean, maxtime
  while (thisPtr != nullptr) {
    temp = thisPtr->get_departureTime() - thisPtr->get_arrivalTime();
    if (temp > maxTime) {
      maxTime = temp;
    }
    avgTime += temp;
    cnt++;
    thisPtr = thisPtr->get_next();
  }
  avgTime /= cnt;
  thisPtr = doneList->get_head();  // now get sd
  while (thisPtr != nullptr) {
    temp = pow(
        thisPtr->get_departureTime() - thisPtr->get_arrivalTime() - avgTime, 2);
    sdTime += temp;
    thisPtr = thisPtr->get_next();
  }
  sdTime = pow(sdTime / cnt, 0.5);
  cout << "Finished at time " << expTimeElapsed << endl
       << "Statistics: " << endl
       << "Maximum wait time: " << maxTime << endl
       << "Average wait time: " << avgTime << endl
       << "Standard Deviation of wait time: " << sdTime << endl;
  // You have to make sure all dynamically allocated memory is freed
  // before return 0
  delete registerList;
  delete doneList;
  delete singleQueue;
  return 0;
}

string getMode() {
  string mode;
  cout << "Welcome to ECE 244 Grocery Store Queue Simulation!" << endl;
  cout << "Enter \"single\" if you want to simulate a single queue or "
          "\"multiple\" to "
          "simulate multiple queues: \n> ";
  getline(cin, mode);

  if (mode == "single") {
    cout << "Simulating a single queue ..." << endl;
  } else if (mode == "multiple") {
    cout << "Simulating multiple queues ..." << endl;
  }
  return mode;
}

void addCustomer(stringstream &lineStream, string mode) {
  int items;
  double timeElapsed;
  if (!getInt(lineStream, items) || !getDouble(lineStream, timeElapsed)) {
    cout << "Error: too few arguments." << endl;
    return;
  }
  if (foundMoreArgs(lineStream)) {
    cout << "Error: too many arguments." << endl;
    return;
  }
  // Depending on the mode of the simulation (single or multiple),
  // add the customer to the single queue or to the register with
  // fewest items
  update(mode, timeElapsed);
  expTimeElapsed += timeElapsed;
  cout << "A customer entered" << endl;
  Customer *customer = new Customer(expTimeElapsed, items);
  if (mode == "single") {
    Register *selected = registerList->get_free_register();
    if (selected != nullptr) {
      selected->get_queue_list()->enqueue(customer);
      cout << "Queued a customer with free register " << selected->get_ID()
           << endl;
    } else {
      singleQueue->enqueue(customer);
      cout << "No free registers" << endl;
    }
  } else {  // mutiple
    registerList->get_min_items_register()->get_queue_list()->enqueue(customer);
  }
}

void parseRegisterAction(stringstream &lineStream, string mode) {
  string operation;
  lineStream >> operation;
  if (operation == "open") {
    openRegister(lineStream, mode);
  } else if (operation == "close") {
    closeRegister(lineStream, mode);
  } else {
    cout << "Invalid operation" << endl;
  }
}

void openRegister(stringstream &lineStream, string mode) {
  int ID;
  double secPerItem, setupTime, timeElapsed;
  // convert strings to int and double
  if (!getInt(lineStream, ID) || !getDouble(lineStream, secPerItem) ||
      !getDouble(lineStream, setupTime) ||
      !getDouble(lineStream, timeElapsed)) {
    cout << "Error: too few arguments." << endl;
    return;
  }
  if (foundMoreArgs(lineStream)) {
    cout << "Error: too many arguments" << endl;
    return;
  }
  // Check if the register is already open
  // If it's open, print an error message
  // Otherwise, open the register
  // If we were simulating a single queue,
  // and there were customers in line, then
  // assign a customer to the new register
  if (registerList->foundRegister(ID)) {
    cout << "Error: register " << ID << " is already open." << endl;
  } else {
    update(mode, timeElapsed);
    expTimeElapsed += timeElapsed;
    Register *reg = new Register(ID, secPerItem, setupTime, expTimeElapsed);
    registerList->enqueue(reg);
    cout << "Opened register " << ID << endl;
    if (mode == "single" && singleQueue->get_head() != nullptr) {
      reg->get_queue_list()->enqueue(singleQueue->dequeue());
      cout << "Queued a customer with free register " << ID << endl;
    }
  }
}

void closeRegister(stringstream &lineStream, string mode) {
  int ID;
  double timeElapsed;
  // convert string to int
  if (!getInt(lineStream, ID) || !getDouble(lineStream, timeElapsed)) {
    cout << "Error: too few arguments." << endl;
    return;
  }
  if (foundMoreArgs(lineStream)) {
    cout << "Error: too many arguments" << endl;
    return;
  }
  // Check if the register is open
  // If it is open dequeue it and free it's memory
  // Otherwise, print an error message
  if (registerList->foundRegister(ID)) {
    update(mode, timeElapsed);
    expTimeElapsed += timeElapsed;
    Register *trash = registerList->dequeue(ID);
    delete trash;
    cout << "Closed register " << ID << endl;
  } else {
    cout << "Error: register " << ID << " is not open." << endl;
  }
}

bool getInt(stringstream &lineStream, int &iValue) {
  // Reads an int from the command line
  string command;
  lineStream >> command;
  if (lineStream.fail()) {
    return false;
  }
  iValue = stoi(command);
  return true;
}

bool getDouble(stringstream &lineStream, double &dvalue) {
  // Reads a double from the command line
  string command;
  lineStream >> command;
  if (lineStream.fail()) {
    return false;
  }
  dvalue = stod(command);
  return true;
}

bool foundMoreArgs(stringstream &lineStream) {
  string command;
  lineStream >> command;
  if (lineStream.fail()) {
    return false;
  } else {
    return true;
  }
}

void update(
    string mode,
    double time) {  // what happens when a certain amount of time has passed
  for (double iteratedTime = expTimeElapsed;
       iteratedTime <= time + expTimeElapsed; iteratedTime += 0.01) {
    Register *thisReg = registerList->get_head();
    while (thisReg != nullptr) {
      double cTime = thisReg->calculateDepartTime() + expTimeElapsed;
      if (cTime != -1 && cTime <= iteratedTime) {
        thisReg->departCustomer(doneList);
        cout << "Departed a customer at register ID " << thisReg->get_ID()
             << "at " << iteratedTime << endl;
        if (mode == "single" && singleQueue->get_head() != nullptr) {
          thisReg->get_queue_list()->enqueue(singleQueue->dequeue());
          cout << "Queued a customer with free register " << thisReg->get_ID()
               << endl;
        }
      }
      thisReg = thisReg->get_next();
    }
  }
}