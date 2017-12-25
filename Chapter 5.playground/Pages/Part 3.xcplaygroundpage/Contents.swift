//: [Previous](@previous)
/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 3: The If-Statement
 Let's run through our masterplan once again.
 
 To make this happen,
 ```
          Branch if NOT <Condition> to <L>
          A
 <Label>: B
 ```
 We must make the following things happen
 
 ```
 IF <condition> -> { eval_condition()
                     let l = newLabel()
                     emitMsg(Branch False to L); }
 
 <block>
 
 ENDIF          ->  { postLabel(l) }
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

/*:
 ### doIf()
 On the 68000 there are two branch instructions.
 - `BEQ` (branch if false)
 - `BNE` (branch if true)
 
 ```
 i -> IF
 e -> ENDIF
 ```
 For now, we will completely skip the character for the branch `condition`.
 */
func doIf() {
  LOOK.match("i")
  let label = newLabel()
  condition()
  emitLine(msg: "BEQ \(label)")
  block()
  LOOK.match("e")
  postLabel(label)
}

/*:
 ### condition()
 This function will later parse and translate any boolean condition we give it within our if-statement.
 
 > Once again, this is be a dummy version for now. We will make this work soon enough though 😀
 */
func condition() {
  emitLine(msg: "<condition>")
}

/*:
 ### block()
 Our block now recognizes `i` for `if` and `default` for `other` miscellaneous operations.
 */
func block() {
  while let cur = LOOK.cur, !(["e"].contains(cur)) {
    switch cur {
    case "i":
      doIf()
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
 The input `aibece` translates to
 ```
 A
 IF <condition>
   B
 ENDIF
 C
 END
 ```
 > Try something more complicated like `aibicedefe`. The output looks cool, eh??
 
 Now, all we have to do is add the `else` clause and other constructs!
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "aibece")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()

//: [Next](@next)
