#include "RegisterList.h"

#include <iostream>

#include "Register.h"
using namespace std;

RegisterList::RegisterList() {
  head = nullptr;
  size = 0;
}

RegisterList::~RegisterList() {
  // Delete all registers in the list
  Register* thisPtr = head;
  Register* lastPtr;
  while (thisPtr != nullptr) {
    lastPtr = thisPtr;
    thisPtr = thisPtr->get_next();
    delete lastPtr;
  }
  size = 0;
}

Register* RegisterList::get_head() { return head; }

int RegisterList::get_size() {
  // return number of registers
  return size;
}

Register* RegisterList::get_min_items_register() {
  // loop all registers to find the register with least number of items
  Register* foundRegister = head;
  Register* thisPtr = head;
  while (thisPtr != nullptr) {
    if (thisPtr->get_queue_list()->get_items() <
        foundRegister->get_queue_list()->get_items()) {
      foundRegister = thisPtr;
    };
    thisPtr = thisPtr->get_next();
  }
  return foundRegister;
}

Register* RegisterList::get_free_register() {
  // return the register with no customers
  // if all registers are occupied, return nullptr
  Register* thisPtr = head;
  while (thisPtr != nullptr) {
    if (thisPtr->get_queue_list()->get_head() == nullptr) {
      return thisPtr;
    }
    thisPtr = thisPtr->get_next();
  }
  return nullptr;
}

void RegisterList::enqueue(Register* newRegister) {
  // a register is placed at the end of the queue
  // if the register's list is empty, the register becomes the head
  // Assume the next of the newRegister is set to null
  // You will have to increment size
  if (head == nullptr) {
    head = newRegister;
  } else {
    Register* lastPtr = head;
    while (lastPtr->get_next() != nullptr) {
      lastPtr = lastPtr->get_next();
    }
    lastPtr->set_next(newRegister);
  }
  size++;
}

bool RegisterList::foundRegister(int ID) {
  // look for a register with the given ID
  // return true if found, false otherwise
  Register* thisPtr = head;
  while (thisPtr != nullptr) {
    if (thisPtr->get_ID() == ID) {
      return true;
    }
    thisPtr = thisPtr->get_next();
  }
  return false;
}

Register* RegisterList::dequeue(int ID) {
  // dequeue the register with given ID
  Register* delPtr = nullptr;
  Register* thisPtr = head;
  Register* lastPtr = nullptr;
  while (thisPtr != nullptr) {
    if (thisPtr->get_ID() == ID) {
      if (thisPtr == head) {
        head = thisPtr->get_next();
      } else if (thisPtr->get_next() == nullptr) {
        lastPtr->set_next(nullptr);
      } else {
        lastPtr->set_next(thisPtr->get_next());
      }
      thisPtr->set_next(nullptr);
      delPtr = thisPtr;
      break;
    }
    lastPtr = thisPtr;
    thisPtr = thisPtr->get_next();
  }
  return delPtr;
  // return the dequeued register
  // return nullptr if register was not found
}

Register* RegisterList::calculateMinDepartTimeRegister(double expTimeElapsed) {
  // return the register with minimum time of departure of its customer
  // if all registers are free, return nullptr
  Register* foundRegister = head;
  Register* thisPtr = head;
  bool allFree = true;
  while (thisPtr != nullptr) {
    if (thisPtr->calculateDepartTime() < foundRegister->calculateDepartTime()) {
      foundRegister = thisPtr;
    }
    if (thisPtr->calculateDepartTime() != -1) {
      allFree = false;
    }
    thisPtr = thisPtr->get_next();
  }
  if (allFree) {
    return nullptr;
  }
  return foundRegister;
}

void RegisterList::print() {
  Register* temp = head;
  while (temp != nullptr) {
    temp->print();
    temp = temp->get_next();
  }
}
