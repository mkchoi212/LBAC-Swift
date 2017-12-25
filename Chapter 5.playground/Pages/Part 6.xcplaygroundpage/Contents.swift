//: [Previous](@previous)
/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 6: Loop Statement
 
 So far, we gave the compiler the ability to parse `IF` and a `WHILE`.
 
Now, we are going to add support for **INFINITE LOOPS**!
 
 What's the point of this?
 Well, not much for now but we will later add a `BREAK` so we can escape from the infinite loop.
 
 ```
 LOOP <block> ENDLOOP
 ```
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
  emitLine(msg: "\(getName())")
}

func condition() {
  emitLine(msg: "<condition>")
}

/*:
 ### doLoop()
 Since `l` is taken, we will use `p` to denote LOO**P**
 ```
 LOOP           { L = newLabel()
                  postLabel(L) }
 <block>
 ENDLOOP        { emit(BRA L)  }
  ```
 
 Notice that at `ENDLOOP -> emit(BRA L)`, the code branches (`BRA`) back to label `L`, which is the beginning of the `LOOP` statement.
 */
func doLoop() {
  match("p")
  let label = newLabel()
  postLabel(label)
  block()
  match("e")
  emitLine(msg: "BRA \(label)")
}

func doWhile() {
  var L1, L2: String
  match("w")
  L1 = newLabel()
  L2 = newLabel()
  postLabel(L1)
  condition()
  emitLine(msg: "BEQ \(L2)")
  block()
  match("e")
  emitLine(msg: "BRA \(L1)")
  postLabel(L2)
}

func doIf() {
  var L1, L2: String
  
  match("i")
  condition()
  L1 = newLabel()
  L2 = L1
  emitLine(msg: "BEQ \(L1)")
  block()
  
  if let cur = LOOK.cur, cur == "l" {
    match("l")
    L2 = newLabel()
    emitLine(msg: "BRA \(L2)")
    postLabel(L1)
    block()
  }
  
  match("e")
  postLabel(L2)
}

/*:
 ### block()
 Recognizes `p` for `LOOP`
 */
func block() {
  while let cur = LOOK.cur, !(["e", "l"].contains(cur)) {
    switch cur {
    case "i":
      doIf()
    case "w":
      doWhile()
    case "p":
      doLoop()
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
 Once again, adding constructs is not hard at all 😎
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "apze")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()
//: [Next](@next)
