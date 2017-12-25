//: [Previous](@previous)
/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 8: For Loop
 
 The `for-loop` is one of the most used constructs. And you'd think that it's just a slightly different version of the `LOOP` statement we made previously... but you'd be wrong.
 
 `for-loop`s are kind of tricky to implement in assembly 😨
 
 But no need to worry too much! Once we get the assembly code figured out, the translation isn't too hard.
 
 ### THE LOOP
 Our `for-loop` will look something like this.
 ```
 FOR <ident> = <expr1> TO <expr2>
 <block>
 ENDFOR
 ```
 
 We are going to consider this to be equivalent to this alternate `for-loop`.
 
 ```
 <ident> = <expr1>
 TEMP = <expr2>
 WHILE <ident> <= TEMP
 <block>
 ENDWHILE
 ```
 Once you understand what just happened in the above code segment, you should be fine. If you don't, try to go through each step of the for-loop to see what is actually happening to the variables within the loop.
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

/*:
 ### expression()
 This function will be a dummy function for all expressions
 */
func expression() {
  emitLine(msg: "<expr>")
}

/*:
 ### doFor()
 
 So... here is the `for-loop` in assembly`
 ```
 <ident>             get name of loop counter
 <expr1>             get initial value
 LEA <ident>(PC),A0  address the loop counter
 SUBQ #1,D0          predecrement it
 MOVE D0,(A0)        save it
 <expr1>             get upper limit
 MOVE D0,-(SP)       save it on stack
 
 L1:  LEA <ident>(PC),A0  address loop counter
 MOVE (A0),D0        fetch it to D0
 ADDQ #1,D0          bump the counter
 MOVE D0,(A0)        save new value
 CMP (SP),D0         check for range
 BLE L2              skip out if D0 > (SP)
 <block>
 BRA L1              loop for next pass
 L2:  ADDQ #2,SP     clean up the stack
 ```
 Got it? Good.
 > If you don't - I didn't when I first saw this - just try to understand the alternate version of the `for-loop` in the top of the Playground.
 */

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
 Recognizes `f` for `FOR`
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
 > We don't have any input for the dummy version of the `expression`. So a typical input would be something like the following.
 
 `afi=bece`
 
 ```
 a
 FOR i = <expr1> to <expr2>
 b
 ENDFOR
 c
 ```
 
 I know the program genertes a lot of code for what seems to be a simple `for-loop`. So try to take your time through this to try to understand how a `for-loop` actually works underneath.
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "afi=bece")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()
//: [Next](@next)
