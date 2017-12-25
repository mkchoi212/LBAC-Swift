//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IX: A Top View
 ## Part 2: Fleshing it Out
 To make our compiler, we only need to make the features of the language, one by one. We will first start with empty procedures and add the details incrementally.
 
 Let's start by processing a block of code.
 */

func postLabel(_ label: String) {
  print("\(label):", terminator:"")
}

func declarations() {
}


func statements() {
}

/*:
 ### doBlock()
 The code in `doBlock` reflects what a block should look like. Declarations followed by statements.
 
 The insertion of label via `postLabel` has to do with the operation of SK*DOS. Unlike most OS's, SK*DOS allows the entry point to the main program to be anywhere in the program. All you have to do is give that point a name.
 
 `postLabel` does this by putting that name just before the first `statement`.
 
 > `declarations` and `statements` are dummy functions for now. We will implement them in the next part
 */
func doBlock(name: Character) {
  declarations()
  postLabel(String(name))
  statements()
}

func prolog() {
  emitLine(msg: "WARMST EQU $A01E")
}

func epilog(_ name: Character) {
  emitLine(msg: "DC WARMST")
  emitLine(msg: "END \(name)")
}

/*:
 ### So far...
 Note that prog now handles blocks with `doBlock()`
 */
func prog() {
  LOOK.match("p")
  let name = LOOK.getName()
  prolog()
  doBlock(name: name)
  LOOK.match(".")
  epilog(name)
}

func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "px.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()
//: [Next](@next)
