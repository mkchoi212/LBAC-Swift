//: [Previous](@previous)
/*:
 # LBaC
 # Chapter X: Introducing "TINY"
 ## Part 4: Declarations and Symbols
 
 Let's produce some actual code for declarations!
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
 ### alloc()
 Just writes command to assembler to allocate storage. Nothing to it.
 */
func alloc(_ n: Character) {
  emitLine(msg: "\(n):\tDC 0")
}

/*:
 ### decl()
 Let's allocate the variable now!
 
 And since TINY supports a variable list as such
 ```
 var a, b, c, d
 ```
 let's make that happen as well.
 */
func decl() {
  LOOK.match("v")
  alloc(LOOK.getName())
  while let cur = LOOK.cur, cur == "," {
    LOOK.getChar()
    alloc(LOOK.getName())
  }
}

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
 Notice the output of the Playground to see how variables are allocated.
 
 > A "real" compiler would also have a symbols table. We will ignore them for now until we need to make one.
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "pva,b,cbe.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
  abort(msg: "Unexpected data after `.`")
}

//: [Next](@next)
