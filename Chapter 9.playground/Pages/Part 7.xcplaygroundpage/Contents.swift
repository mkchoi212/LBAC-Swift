//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IX: A Top View
 ## Part 7: C (continued)
 
 Let's make `getClass` and `getType` do something more interesting...
 
 > Global variables `CLASS`, `SIGN` and `TYPE` have been created
 */

var CLASS : Character!
var SIGN : Character!
var TYPE: Character!

func postLabel(_ label: String) {
  print("\(label):", terminator:"")
}

/*:
 ### getClass()
 Three single characters are used to represent storage classes
 - a - `auto`
 - x - `extern`
 - s - `static`
 
 We are missing `register` and `extern` but we will ignore them for now.
 
 > Default class is `a` or `auto`
 */
func getClass() {
  if let cur = LOOK.cur, ["a", "x", "s"].contains(cur) {
    CLASS = cur
    LOOK.getChar()
  } else {
    CLASS = "a"
  }
}

/*:
 ### getType()
 
 We will do something very similar to `getClass` with `getType`
 - u - `unsigned`
 - s - `signed`
 - i - `int`
 - l - `long`
 - c - `char`
 */
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

func topDecl() {
  LOOK.getChar()
}

func prog() {
  while LOOK.cur != nil {
    getClass()
    getType()
    topDecl()
  }
}

/*:
 ### So far...
 `sih` represents
 ```
 static int h;
 ```
 
 We have a long ways to go still.
 
 For example, there are many complexities involving just the definition of a type, before we can start talking about actual data/function names.
 
 > But for now, we will ignore all of those complexities; for the sake of swift learning!
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "sih")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()
//: [Next](@next)
