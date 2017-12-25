//: [Previous](@previous)
/*:
 # LBaC
 # Chapter VI: Boolean Expressions
 ## Part 4: Merging with control constructs
 
 Here, we are going to merge the code we previously wrote to support control constructs with the boolean expression parsing code have been writing.
 
 All we are going to do is the following
 1. Copy and paste the old control construct parsing code from `Chapter 5/Part 9.playground`
 2. Replace the dummy function `condition` in it with our spanking new `boolExpression`
 
 It's going to look like there is **a lot** of new code but you have seen all this before. So take your time, and walk through memory lane to bring back the good times you've had with control constructs.
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

func boolOr() {
  LOOK.match("|")
  boolTerm()
  emitLine(msg: "OR (SP)+,D0")
}

func boolXor() {
  LOOK.match("~")
  boolTerm()
  emitLine(msg: "EOR (SP)+,D0")
}

func equals() {
  LOOK.match("=")
  expression()
  emitLine(msg: "CMP (SP)+,D0")
  emitLine(msg: "SEQ D0")
}

func notEquals() {
  LOOK.match("#")
  expression()
  emitLine(msg: "CMP (SP)+,D0")
  emitLine(msg: "SNE D0")
}

func less() {
  LOOK.match("<")
  expression()
  emitLine(msg: "CMP (SP)+,D0")
  emitLine(msg: "SGE D0")
}

func greater() {
  LOOK.match(">")
  expression()
  emitLine(msg: "CMP (SP)+,D0")
  emitLine(msg: "SLE D0")
}

func relation() {
  expression()
  if let cur = LOOK.cur, isRelOp(cur) {
    emitLine(msg: "MOVE D0,-(SP)")
    switch cur {
    case "=":
      equals()
    case "#":
      notEquals()
    case "<":
      less()
    case ">":
      greater()
    default:
      expected("Relational operator")
    }
    emitLine(msg: "TST D0")
  }
}

func boolFactor() {
  if let cur = LOOK.cur, isBoolean(cur) {
    if LOOK.getBoolean() {
      emitLine(msg: "MOVE #-1,D0")
    } else {
      emitLine(msg: "CLR D0")
    }
  } else {
    relation()
  }
}

func notFactor() {
  if let cur = LOOK.cur, cur == "!" {
    LOOK.match("!")
    boolFactor()
    emitLine(msg: "EOR #-1,D0")
  } else {
    boolFactor()
  }
}

func boolTerm() {
  notFactor()
  while let cur = LOOK.cur, cur == "&" {
    emitLine(msg: "MOVE D0,-(SP)")
    LOOK.match("&")
    notFactor()
    emitLine(msg: "AND (SP)+,D0")
  }
}

func boolExpression() {
  boolTerm()
  while let cur = LOOK.cur, isOrOp(cur) {
    emitLine(msg: "MOVE D0,-(SP)")
    switch cur {
    case "|":
      boolOr()
    case "~":
      boolXor()
    default:
      expected("| or ~")
    }
  }
}

func indent() {
  let name = LOOK.getName()
  if let cur = LOOK.cur, cur == "(" {
    LOOK.match("(")
    LOOK.match(")")
    emitLine(msg: "BSR \(name)")
  } else {
    emitLine(msg: "MOVE \(name)(PC),D0")
  }
}

func factor() {
  guard let cur = LOOK.cur else { return }
  if cur == "(" {
    LOOK.match("(")
    expression()
    LOOK.match(")")
  } else if isAlpha(cur) {
    indent()
  } else {
    emitLine(msg: "MOVE #\(LOOK.getNum()),D0")
  }
}

func multiply() {
  LOOK.match("*")
  factor()
  emitLine(msg: "MULS (SP)+,D1")
}

func divide() {
  LOOK.match("/")
  factor()
  emitLine(msg: "MULS (SP)+,DO")
  emitLine(msg: "DIVS D1, D0")
}

func add() {
  LOOK.match("+")
  term()
  emitLine(msg: "ADD (SP)+,D0")
}

func subtract() {
  LOOK.match("-")
  term()
  emitLine(msg: "SUB (SP)+,D0")
  emitLine(msg: "NEG D0")
}

func term() {
  factor()
  
  while let cur = LOOK.cur, ["*","/"].contains(cur) {
    emitLine(msg: "MOVE D0,-(SP)")
    switch String(cur) {
    case "*":
      multiply()
    case "/":
      divide()
    default:
      expected("* or /")
    }
  }
}

func expression() {
  term()
  while let cur = LOOK.cur, addOp.contains(cur) {
    emitLine(msg: "MOVE D0,-(SP)")
    switch String(cur) {
    case "+":
      add()
    case "-":
      subtract()
    default:
      expected("+ or -")
    }
  }
}


/*:
 ## Old control construct code
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
      LOOK.other()
    }
  }
}

/*:
 > Every call to this dummy function `condition` has been replaced with `boolExpression
 ```
 func condition() {
  emitLine(msg: "<condition>")
 }
 ```
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
  // Bye bye dummy function 👊
  // condition()
  boolExpression()
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
  // Bye bye dummy function 👊
  // condition()
  boolExpression()
  emitLine(msg: "BEQ \(L2)")
  block()
  LOOK.match("e")
  emitLine(msg: "BRA \(L1)")
  postLabel(L2)
}

func doIf() {
  var L1, L2: String
  
  LOOK.match("i")
  // Bye bye dummy function 👊
  // condition()
  boolExpression()
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

func program() {
  block()
  if let cur = LOOK.cur, cur != "e" {
    expected("End")
  }
  emitLine(msg: "END")
}

/*:
 ### So far...
 The sample input `ia=bxlye` means
 ```
 IF a=b X ELSE Y ENDIF
 ```
 
 Wow.... this looks like a legit programming language... 🤯🤯🤯
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "ia=bxlye")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()
//: [Next](@next)
