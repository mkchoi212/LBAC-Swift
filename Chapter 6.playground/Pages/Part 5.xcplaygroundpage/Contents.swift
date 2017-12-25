//: [Previous](@previous)
/*:
 # LBaC
 # Chapter VI: Boolean Expressions
 ## Part 5: Adding Assignments
 
 The last thing we are going to do is support assignment statements.
 
 But since single line statements are getting very limiting very fast, we are going to support multi-line statements while at it.
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
 ### fin()
 This function will skip carriage returns and line feeds so we can write multiple lines of code!
 */
func fin() {
  if let cur = LOOK.cur, cur == "\n" || cur == "\r" {
    LOOK.getChar()
  }
}

/*:
 ## Assignment function from previous chapters
 */
func assignment() {
  let name = LOOK.getName()
  LOOK.match("=")
  boolExpression()
  emitLine(msg: "LEA \(name)(PC),A0")
  emitLine(msg: "MOVE D0,(A0)")
}

/*:
 > Call to `other()` as the default case has been switched to `assignment()`
 >
 > Also, notice the two calls to `fin()` to eat up CR and LF
 */
func block() {
  while let cur = LOOK.cur, !(["e", "l", "u"].contains(cur)) {
    fin()       // Eat NewLines
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
      assignment()
    }
    fin()       // Eat NewLines
  }
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
 ```
 a=3+2\n
 ia=bx=aly=2e
 ```
 in the sample input means
 ```
 a = 3 + 2
 if a == b:
  x = a
 else
  y = 2
 ```
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "a=3+2\nia=bx=aly=2e")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
program()

/*:
 ## Conclusion
 Ok, so we just wrote a reasonably realistic looking program 🎉🎉🎉
 
 We wrote a lot of code and had to take in some heavy material so congratulate yourself for having coming this far 👏👏👏
 
 Looking at our compiler, we still have the *limitation of single character tokens.*
 To get rid of this, we would need a true **lexical scanner**, which requires some structural changes to the code.
 The changes aren't so big that we have to throw away everything we have written so far but they do require some care.
 
 But a compiler without multi-character tokens is 😟. And so, we will do this in the next chapter to write our **first complete compiler** 😃
 
 ---
 ### End of Chapter 6
 */
