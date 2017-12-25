//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IX: A Top View
 ## Part 4: Statements
 We will be `statements()` but here's something to 🤔 about.
 
 We have been adding functions but the output of the program hasn't changed. And it's the way it's supposed to be.
 
 This high in the levels - *remember we are going from high to low now* - we don't need to emit code. The recognizers' job is to just recognize. They accept lines, catch bad ones and channel good ones to the right place.
 */

func postLabel(_ label: String) {
  print("\(label):", terminator:"")
}

func labels() {
  LOOK.match("l")
}

func types() {
  LOOK.match("t")
}

func constants() {
  LOOK.match("c")
}

func variables() {
  LOOK.match("v")
}

func doProcedure() {
  LOOK.match("p")
}

func doFunction() {
  LOOK.match("f")
}

func declarations() {
  let decTypes : Set<Character> = Set(["l", "c", "t", "v", "p", "f"])
  while let cur = LOOK.cur, decTypes.contains(cur) {
    switch cur {
    case "l":
      labels()
    case "c":
      constants()
    case "t":
      types()
    case "v":
      variables()
    case "p":
      doProcedure()
    case "f":
      doFunction()
    default:
      break
    }
  }
}

/*:
 ### statements()
 Grammatically, statements can begin with any identifier except `END`. It can also be represented like this
 ```
 BEGIN
 <statement>;
 END
 ```
 First semi-dummy version of `statement()` can be written like this.
 */
func statements() {
  LOOK.match("b")                                      // `b` stands for `BEGIN`
  while let cur = LOOK.cur, cur != "e" {
    LOOK.getChar()                                // Just eat characters for now
  }
  LOOK.match("e")                                      // `e` stands for `END`
}

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

func prog() {
  LOOK.match("p")
  let name = LOOK.getName()
  prolog()
  doBlock(name: name)
  LOOK.match(".")
  epilog(name)
}

/*:
 ### BEGIN and END
 The compiler will now accept any number of declarations that are followed by the `BEGIN` block.
 
 IOW, the simplest form of input is
 ```
 pxbe.
 ```
 > Try it and various other combinations!
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "pxbwhatsupe.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()

/*:
 ## Intermission
 
 At this point, we could have to expanded `statements()` in order to make the compiler somewhat useful. The expansion would include things like `if/case/while/for` statements.
 
 But since we have already gone through this process of parsing assignment and control structures in previous chapters, we won't do it again. But do you see how **this is where the top level meets our old bottom-up approach? **The constructs will be little different now but the differences will probably be very minor.
 
 > So, **we will now stop trying to write a Pascal compiler.** Instead, we will now spend time making a **C Compiler**. Say whuuuutttt 🤨
 */
//: [Next](@next)
