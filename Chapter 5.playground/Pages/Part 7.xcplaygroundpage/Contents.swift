//: [Previous](@previous)
/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 7: Repeat Until
 ```
 REPEAT <block> UNTIL <condition>
 ```
 */

var LCNT: Int = 0

func expected(_ s: String) {
  abort(msg: "\(s) expected")
}

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

/*:
 ### doRepeat
 ```
 REPEAT         { L = newLabel()
                  postLabel(L) }
 <block>
 UNTIL
 <condition>    { emit(BEQ L) }
 ```
 Similar thing to `LOOP` happens here. However, instead of an unconditional branch `BRA`, we use a `BEQ` to check for the condition parsed from `UNTIL`.
 
 ```
 r -> REPEAT
 u -> UNTIL
 ```
 */

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
 Recognizes `r` for `REPEAT`
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
 Another useful construct is in the books!
 
 We have couple more construct to cover and the next one may be the most important one of them all; the `for-loop` 😱😱😱
 */

func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "arxuye")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()
//: [Next](@next)
