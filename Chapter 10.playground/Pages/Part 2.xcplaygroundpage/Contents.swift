//: [Previous](@previous)
/*:
 # LBaC
 # Chapter X: Introducing "TINY"
 ## Part 2: Begin Blocks
 When processing code in the main program, we will use **BEGIN-blocks** from Pascal.
 
 We could also require a *name* for the program like such
 ```
 BEGIN <name>
 END <name>
 ```
 to make things clear. But this is just **syntactic sugar**. You can add this later if you'd like to.
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

/*:
 ### main()
 The syntax of the BEGIN-block is the following. `main()` directly reflects the syntax.
 ```
 BEGIN
 <MAIN PROGRAM>
 END
 ```
 */
func main() {
  LOOK.match("b")
  prolog()
  LOOK.match("e")
  epilog()
}

/*:
 ### prog()
 > `prolog`, `epilog`, and BEGIN-blocks have been added via `main`
 */

func prog() {
  LOOK.match("p")
  header()
  main()
  LOOK.match(".")
}

/*:
 ### So far...
 ```
 PROGRAM
 BEGIN
 END
 .
 ```
 or `pbe.` is the only legal program.
 
 We are rolling with steam and making progress 🚂🚂🚂.
 
 > Try deliberately making errors and see what happens; like leaving out a `b`. The compiler should catch the errors!!
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "pbe.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
  abort(msg: "Unexpected data after `.`")
}
//: [Next](@next)
