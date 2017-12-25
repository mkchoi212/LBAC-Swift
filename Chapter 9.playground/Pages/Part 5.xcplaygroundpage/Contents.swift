//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IX: A Top View
 ## Part 5: Small C
 C is a completely different beast 🐶
 
 C has less structure than Pascal and at the top level, everything is a *static declaration* of either data or a function.
 */

func postLabel(_ label: String) {
  print("\(label):", terminator:"")
}

func preProcess() {
  LOOK.match("#")
}

func intDecl() {
  LOOK.match("i")
}

func charDecl() {
  LOOK.match("c")
}

/*:
 ## Small C
 We are interested in the full C but we will first briefly look at the top-level structure of Small C to get of taste of what is to come.
 
 In Small C, **functions can only have default type int**, which is not explicitly declared.
 
 This makes the input easy to parse. First token is either `int` or `char`, or the name of the function.
 */
func prog() {
  while let cur = LOOK.cur {
    switch cur {
    case "#":
      preProcess()
    case "i":
      intDecl()
    case "c":
      charDecl()
    default:
      break
    }
  }
}

/*:
 ### So far...
 `ic.` is equavalent to
 
 ```
 int c;
 ```
 
 Implementing the full-blown version of C is much harder than this.
 
 The problem is that in full C, functions can also have types. **So when the compiler sees a keyword `int`, it still doesn't know whether to expect a data declaration or a function definition.**
 
 We will explore more into how to do this in the next part.
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "ic.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()
//: [Next](@next)
