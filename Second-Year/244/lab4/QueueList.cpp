#include "QueueList.h"

#include "Customer.h"

QueueList::QueueList() { head = nullptr; }

QueueList::QueueList(Customer* customer) { head = customer; }

QueueList::~QueueList() {
  while (head != nullptr) {
    dequeue();
  }
}

Customer* QueueList::get_head() { return head; }

void QueueList::enqueue(Customer* customer) {
  // a customer is placed at the end of the queue
  // if the queue is empty, the customer becomes the head
  if (head == nullptr) {
    head = customer;
  } else {
    Customer* lastPtr = head;
    while (lastPtr->get_next() != nullptr) {
      lastPtr = lastPtr->get_next();
    }
    lastPtr->set_next(customer);
  }
}

Customer* QueueList::dequeue() {
  // remove a customer from the head of the queue
  // and return a pointer to it
  if (head == nullptr) {
    return nullptr;
  }
  Customer* delPtr = head;
  head = head->get_next();
  delPtr->set_next(nullptr);
  return delPtr;
}

int QueueList::get_items() {
  // count total number of items each customer in the queue has
  int cnt = 0;
  Customer* thisPtr = head;
  while (thisPtr != nullptr) {
    cnt += thisPtr->get_numOfItems();
    thisPtr = thisPtr->get_next();
  }
  return cnt;
}

bool QueueList::empty_queue() {
  // if the queue is empty, return false
  // if the queue is not empty, delete all customers
  // and return true
  if (head == nullptr) {
    return false;
  } else {
    while (head != nullptr) {
      delete dequeue();
    }
    return true;
  }
}

void QueueList::print() {
  // print customers in a queue
  Customer* temp = head;
  while (temp != nullptr) {
    temp->print();
    temp = temp->get_next();
  }
}
