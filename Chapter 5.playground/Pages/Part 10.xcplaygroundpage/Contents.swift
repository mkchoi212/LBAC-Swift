//: [Previous](@previous)
//: [Previous](@previous)
/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 10: Break Statement

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
 
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "adb")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()

