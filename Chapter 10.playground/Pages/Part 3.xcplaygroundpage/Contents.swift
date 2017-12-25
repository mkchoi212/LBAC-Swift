//: [Previous](@previous)
/*:
 # LBaC
 # Chapter X: Introducing "TINY"
 ## Part 3: Declarations
 
 For `TINY`, we will have 2 types of declarations
 1. Variables
 2. Functions
 
 For now, we will deal only with variable declarations; denoted by `VAR` or `v`
 
 > At the top level, only global declarations are allowed; just like C.
 */


func header() {
  emitLine(msg: "WARMST\tEQU $A01E")
}

func prolog() {
  postLabel("MAIN")
}

func epilog() {
  emitLine(msg: "DC WARMST")
  emitLine(msg: "END MAIN")
}

func main() {
  LOOK.match("b")
  prolog()
  LOOK.match("e")
  epilog()
}

/*:
 ### decl()
 This function parses data declarations but is a stub for now.
 
 > For now, it doesn't generate any code or process a list.
 */
func decl() {
  LOOK.match("v")
  LOOK.getChar()  // STUB
}

/*:
 ### topDecl()
 Since TINY only has one type - 16 bit integer - we don't need to declare the type.
 
 Later for full KISS, we can easily add the type description.
 */
func topDecl() {
  while let cur = LOOK.cur, cur != "b" {
    switch cur {
    case "v":
      decl()
    default:
      abort(msg: "Unrecognized keyword \(cur)")
    }
  }
}

func prog() {
  LOOK.match("p")
  header()
  topDecl()
  main()
  LOOK.match(".")
}

/*:
 ### So far...
 We can now have many declarations that start with a `v` for `VAR`. But they *must be in seperate lines for now*!.
 
 > Try a couple of cases and see what happens!
 ```
 PROGRAM
 VAR a
 VAR c
 BEGIN
 END
 ```
 is denoted by `pvavcbe.`
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "pvavcbe.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
  abort(msg: "Unexpected data after `.`")
}
//: [Next](@next)
