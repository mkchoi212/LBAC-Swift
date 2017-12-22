//: [Previous](@previous)
/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 9: Do Statement
 
 The `for-loop` we made previously could've been simpler, right?
 The reason for the massive amount of code in `doFor` was to have
 the loop counter accessible as a variable within the loop.
 
 **But what if we just needed a counting loop that goes through something `x` number of times without needing access to the counter itself?** I reckon this would be a lot easier to implement.
 
 This is where the `do-statement` comes in!
 
 And turns out, 680000 has a "decrement and branch nonzero" operation that would be perfect for this.
 */
var LCNT: Int = 0

func newLabel() -> String {
  let label = "L\(String(LCNT))"
  LCNT += 1
  return label
}

func postLabel(_ label: String) {
  print("\(label):", terminator:"")
}

func other() {
  emitLine(msg: "\(LOOK.getName())")
}

func condition() {
  emitLine(msg: "<condition>")
}

func expression() {
  emitLine(msg: "<expr>")
}

/*:
 ### doDo()
 ```
 DO
 <expr>         {  Emit(SUBQ #1,D0);
                   L = newLabel()
                   postLabel(L)
                   emit(MOVE D0,-(SP) }
 <block>
 ENDDO          { emit(MOVE (SP)+,D0;
                  emit(DBRA D0,L) }
 ```
 This is much easier to implement than the classic `for-loop`.
 */
func doDo() {
  LOOK.match("d")
  let L1 = newLabel()
  expression()
  emitLine(msg: "SUBQ #1,D0")
  postLabel(L1)
  emitLine(msg: "MOVE D0,-(SP)")
  block()
  emitLine(msg: "MOVE (SP)+,D0")
  emitLine(msg: "DBRA D0,\(L1)")
}

func doFor() {
  LOOK.match("f")
  let L1 = newLabel()
  let L2 = newLabel()
  
  let name = LOOK.getName()
  LOOK.match("=")
  expression()
  emitLine(msg: "SUBQ #1,D0")
  emitLine(msg: "LEA \(name)(PC),A0")
  emitLine(msg: "MOVE D0,(A0")
  expression()
  emitLine(msg: "MOVE D0,-(SP)")
  postLabel(L1)
  emitLine(msg: "LEA \(name)(PC),A0")
  emitLine(msg: "MOVE (A0),D0")
  emitLine(msg: "ADDQ #1,D0")
  emitLine(msg: "MOVE D0,(A0)")
  emitLine(msg: "CMP (SP),D0")
  emitLine(msg: "BGT \(L2)")
  block()
  LOOK.match("e")
  emitLine(msg: "BRA \(L1)")
  postLabel(L2)
  emitLine(msg: "ADDQ #2,SP")
}

func doRepeat() {
  LOOK.match("r")
  let label = newLabel()
  postLabel(label)
  block()
  LOOK.match("u")
  condition()
  emitLine(msg: "BEQ \(label)")
}

func doLoop() {
  LOOK.match("p")
  let label = newLabel()
  postLabel(label)
  block()
  LOOK.match("e")
  emitLine(msg: "BRA \(label)")
}

func doWhile() {
  var L1, L2: String
  LOOK.match("w")
  L1 = newLabel()
  L2 = newLabel()
  postLabel(L1)
  condition()
  emitLine(msg: "BEQ \(L2)")
  block()
  LOOK.match("e")
  emitLine(msg: "BRA \(L1)")
  postLabel(L2)
}

func doIf() {
  var L1, L2: String
  
  LOOK.match("i")
  condition()
  L1 = newLabel()
  L2 = L1
  emitLine(msg: "BEQ \(L1)")
  block()
  
  if let cur = LOOK.cur, cur == "l" {
    LOOK.match("l")
    L2 = newLabel()
    emitLine(msg: "BRA \(L2)")
    postLabel(L1)
    block()
  }
  
  LOOK.match("e")
  postLabel(L2)
}

/*:
 ### block()
 `d` is for `DO`
 */
func block() {
  while let cur = LOOK.cur, !(["e", "l", "u"].contains(cur)) {
    switch cur {
    case "i":
      doIf()
    case "w":
      doWhile()
    case "p":
      doLoop()
    case "r":
      doRepeat()
    case "f":
      doFor()
    case "d":
      doDo()
    default:
      other()
    }
  }
}

func program() {
  block()
  if let cur = LOOK.cur, cur != "e" {
    expected("End")
  }
  emitLine(msg: "END")
}

/*:
 ### So far...
 Because we have a `dummy` expression here, again, a typical opeartion using the `do-loop` would look something like below.
 
 We have **one more construct** to go over and that is the `break-statement`!
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "adb")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()
//: [Next](@next)
