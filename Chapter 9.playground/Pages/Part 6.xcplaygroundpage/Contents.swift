//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IX: A Top View
 ## Part 6: C
 
 The big problem with C is that first two parts of the declaration for data and functions can be the same.
 
 ```c
 int this_is_a_var ...
 int this_is_a_func ...
 ```
 
 Because of this, we can't use our original recursive-descent parser method on it. But we can adapt and change it into something that can work here.
 */

func postLabel(_ label: String) {
  print("\(label):", terminator:"")
}

/*:
 ### prog()
 
 The trick we will use to solve the conundrum is this...
 
 > We will build a parsing routine for class and type definitions and have them store away their findings, **all without knowing wheter a function or a data declaration is being processed.**
 
 Notice that all three functions are dummy functions that call `getChar()`
 */
func prog() {
  // The book's while loop runs until `cur == ^Z`
  // but since we are in Playground, we will have to satisfy with nil-checking
  while LOOK.cur != nil {
    getClass()
    getType()
    topDecl()
  }
}

/*:
 ### getClass, getType(), topDecl()
 */
func getClass() {
  LOOK.getChar()
}

func getType() {
  LOOK.getChar()
}

func topDecl() {
  LOOK.getChar()
}

/*:
 ### So far...
 There is nothing interesting going on here.
 
 We will implement all the dummy functions in the next part to do something more exciting 😉
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()

//: [Next](@next)
