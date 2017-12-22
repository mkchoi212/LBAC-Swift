//: [Previous](@previous)
/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 5: While statement
 
 The syntax for a `while` statement is
 ```
 WHILE <condition> <block> ENDWHILE
 ```
 So by now, you probably have noticed the `ENDWHILE` and may be wondering, *"Do we really need a terminator for everything? Sheesh"*.
 
 You are right. We don't need unique terminators for each construct. But remember these extra unique keywords give a bit of error-checking to the user that is worth the extra work for the compiler writer.
 
 So, the job is hand is to translate the above code into this
 ```
 L1:   <condition>
       BEQ L2
       <block>
       BRA L1
 L2:
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

func condition() {
  emitLine(msg: "<condition>")
}

/*:
 ### doWhile()
 ```
 WHILE          { L1 = newLabel()
                  postLabel(L1) }
 <condition>    { emit(BEQ L2)  }
 <block>
 ENDWHILE       { emit(BRA L1)
                  postLabel(L2) }
 ```
 Directly translating the above syntax, we get something like the following.
 */
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
 Now recognizes `w` for `while`!
 */
func block() {
  while let cur = LOOK.cur, !(["e", "l"].contains(cur)) {
    switch cur {
    case "i":
      doIf()
    case "w":
      doWhile()
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
 We have just added support for a `while-statement`. That wasn't too bad, right?
 
 By now, I hope you realize how easy it is to add new constructs if you can just work out the syntax-directed translation of it!
 
 > Try some `if-statements` within the loop or loops within `if-statements`!
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "awbze")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()

//: [Next](@next)
