//: [Previous](@previous)
/*:
 # LBaC
 # Chapter VI: Boolean Expressions
 ## Part 3: Relation Expressions
 
 Here, we are going to **fully implement `relation` and try to connect arithmetic and boolean expressions together.**
 
 A relational operator can be one of the following `["=", "#", "<", ">"]`. IOW, it's an operator that allows you to express the *relation* between two things.
 
 Relation has the form
 ```
 <relation>     ::= | <expression> [<relop> <expression]`
 ```
 
 > Notice how `<b-term>` has been replaced by a **FULL BLOWN** `<expression>` now 😮
 
  To parse `expression`, we will bring back the code we wrote previously to handle arithemtic parsing; remember `expression()`, `indent()` and `factor()`?
 */

let addOp: [Character] = ["+", "-"]

func isRelOp(_ c: Character) -> Bool {
  return ["=", "#", "<", ">"].contains(String(c))
}

/*:
 ## Relation's companion procedures
  - `equals()`
  - `notEquals()`
  - `less()`
  - `greater()`
  - `boorOr()`
  - `boolXor()`
 */
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

/*:
 ### relation()
 
 This is the full blown version of `relation` with support for all the relational operators.
 Doesn't this look familar? Because it looks awefuly similar to  `expression()`!
 */
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

/*:
 ### expression parsing code from the past
 > The following single-character expression parsing code has been copied from `Chapter 3/Part 3.playground`!
 */
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
 ### So far...
 Now we can parse both arithmetic AND boolean algebra! 🚀🚀🚀
 
 Isn't this super cool???? 🤓
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "x>2+3&x<2+5")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
boolExpression()
//: [Next](@next)
