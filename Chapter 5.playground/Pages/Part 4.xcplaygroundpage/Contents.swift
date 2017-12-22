//: [Previous](@previous)
/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 4: ELSE?
 
 An `if-statement` with the `else-clause` in it's full mighty form looks something like this.
 
 ```
 IF <condition> <block> [ ELSE <block>] ENDIF
 ```
 
 The tricky part is that the `ELSE` is **optional**.

 Then, the assembly code we have to produce is this
 ```
       <condition>
       BEQ L1
       <block>
       BRA L2
 L1:   <block>
 L2:   ...
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
  emitLine(msg: "\(LOOK.getName())")
}

func block() {
  while let cur = LOOK.cur, !(["e", "l"].contains(cur)) {
    switch cur {
    case "i":
      doIf()
    default:
      other()
    }
  }
}

func condition() {
  emitLine(msg: "<condition>")
}

/*:
 ### doIf()  // and else
 ```
 IF
 <condtion>    {  L1 = newLabel()
                  L2 = newLabel()
                  emit(BEQ L1) }
 <block>
 ELSE           { emit(BRA L2);
                  postLabel(L1) }
 <block>
 ENDIF          { postLabel(L2) }
 ```
 
 > `l` will denote `else` because `e` already means `END` 🤨
 */
func doIf() {
  var L1, L2: String
  
  LOOK.match("i")
  condition()
  
  L1 = newLabel()
  L2 = L1
  emitLine(msg: "BEQ \(L1)")
  
  block()
  
  // Check if the optional `else` is there
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

func program() {
  block()
  if let cur = LOOK.cur, cur != "e" {
    expected("End")
  }
  emitLine(msg: "END")
}

/*:
 ### So far...
 There we have it! A fully working `if-statement` with support for an `else-clause`.
 
 Just to make sure it works, try an input like `aibece`.
 
 > Try nested `if`s and other cool things.
 >
 > **Just remember character `e` is not a legal `other` statement!**
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "aiblcede")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()
//: [Next](@next)
