//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IX: A Top View
 ## Part 8: C (final)
 
 Assume the next thing we have to tackle is the **name of whatever we are dealing with** in the parser.
 
 If the name is followed by a `(`, we have a **function declaration**.
 
 ```
 int foobar(   <- this is a function!
 ```
 
 If not, we have at least one data item and possibly a list, where each element could have an initializer.
 
 ```
 int foobar,  <- NOT a function
 int foobar, barfoo, ...
 ```
 */

var CLASS : Character!
var SIGN : Character!
var TYPE: Character!

func postLabel(_ label: String) {
  print("\(label):", terminator:"")
}

func getClass() {
  if let cur = LOOK.cur, ["a", "x", "s"].contains(cur) {
    CLASS = cur
    LOOK.getChar()
  } else {
    CLASS = "a"
  }
}

func getType() {
  TYPE = " "
  if let cur = LOOK.cur, cur == "u" {
    SIGN = "u"
    TYPE = "i"
    LOOK.getChar()
  } else {
    SIGN = "s"
  }
  
  if let cur = LOOK.cur, ["i", "l", "c"].contains(cur) {
    TYPE = cur
    LOOK.getChar()
  }
}

/*:
 ### doFunc()
 
 Receive data from `topDecl` and parse the function.
 
 > Our function does not support parameter lists or any code blocks
 */
func doFunc(_ n: Character) {
  LOOK.match("(")
  LOOK.match(")")
  LOOK.match("{")
  LOOK.match("}")
  
  if TYPE == " " {
    TYPE = "i"
  }
  
  emitLine(msg: "\(CLASS!) \(SIGN!) \(TYPE!) function \(n)")
}

/*:
 ### doData()
 
 Receive data from `topDecl` and parse the data
 */
func doData(_ n: Character) {
  var name = n
  
  if TYPE == " " {
    expected("Type Declaration")
  }
  
  emitLine(msg: "\(CLASS!) \(SIGN!) \(TYPE!) data \(name)")
  
  while let cur = LOOK.cur, cur == "," {
    LOOK.match(",")
    name = LOOK.getName()
    emitLine(msg: "\(CLASS!) \(SIGN!) \(TYPE!) data \(name)")
  }
  LOOK.match(";")
}

/*:
 > After we read the name of the declaration, we must pass it to the right function
 */
func topDecl() {
  let name = LOOK.getName()
  if let cur = LOOK.cur, cur == "(" {
    doFunc(name)
  } else {
    doData(name)
  }
}

func prog() {
  while LOOK.cur != nil {
    getClass()
    getType()
    topDecl()
  }
}

/*:
 `ic(){}uca,b,c;` represents
 
 ```
 int c() {
 }
 
 unsigned char a, b, c;
 ```
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "ic(){}uca,b,c;")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()

/*:
 ### So far...
 We are closer but we are still long ways from a C compiler. We are at a good point where we can start to process the right kind of inputs and recognize good from bad inputs.
 
 > We can't process initializers and argument lists for functions
 
 ### Notes on the future
 I don't know about you but I am starting to get a little 😵.
 
 We could continue on with this to make a working compiler but remember that our purpose here is to not build a compiler but to **LEARN** about compilers in general.
 
 ### ⚠️⚠️⚠️
 > From now on, we will start to develop a complete compiler for TINY, a subset of KISS language 💋💋💋
 
 -----
 ### End of Chapter 9
 */
//: [Next](@next)
