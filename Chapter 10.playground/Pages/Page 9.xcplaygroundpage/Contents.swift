//: [Previous](@previous)
/*:
 # LBaC
 # Chapter X: Introducing "TINY"
 ## Part 9: Assignment (NOT FINISHED YET)
 
 It's time to replace the dummy `assignment` function with something that actually generates executable code 🎉🎉🎉
 
 We've already done this in Part VII but we will make some slight changes on the way.

 */

var ST : [Character : Bool] = [:]

func getNum() -> Int {
  var num = 0
  if !isDigit(LOOK.cur) {
    expected("Integer")
  }
  while let cur = LOOK.cur, isDigit(cur) {
    num = num * 10 + Int(String(cur))!
    LOOK.getChar()
  }
  
  return num
}

enum Assembler {
  case Clear, Negate, Push
  case PopAdd, PopSub, PopMul, PopDiv
  case LoadConst(Int), LoadVar(Character)
  case Store(Character)
  case Header, Prolog, Epilog
  
  static func generate(_ cmd: Assembler) {
    var code: String!
    switch cmd {
    case .Clear:
      code = "CLR D0"
    case .Negate:
      code = "MOVE D0, -(SP)"
    case .Push:
      code = "ADD (SP)+, D0"
    case .PopAdd:
      code = "ADD (SP)+,D0"
    case .PopSub:
      code = "SUB (SP)+, D0\nNEG D0"
    case .PopMul:
      code = "MULS (SP)+, D0"
    case .PopDiv:
      code = """
      MOVE (SP)+, D7
      EXT.L D7
      DIVS D0, D7
      MOVE D7, D0"
      """
    case .LoadConst(let n):
      code = "MOVE #\(n), D0"
    case .LoadVar(let n):
      if !isInTable(n) { undefined(n) }
      else { code = "MOVE \(n)(PC), D0}" }
    case .Header:
      code = "WARMST\tEQU $A01E"
    case .Prolog:
      postLabel("MAIN")
      return
    case .Epilog:
      code = "DC WARMST\nEND MAIN"
    case .Store(let n):
      if !isInTable(n) { undefined(n) }
      else { code = "LEA \(n)(PC),A0\nMOVE D0, (A0)" }
    }
    emitLine(msg: code)
  }
  
  static func undefined(_ n: Character) {
    abort(msg: "Undefined Idenifier \(n)")
  }
}

enum Arithematic {
  case Multiply, Divide
  case Add, Subtract
}

func assignment() {
  LOOK.getChar()
}

func block() {
  while LOOK.cur != "e" {
    assignment()
  }
}

func main() {
  LOOK.match("b")
  Assembler.generate(.Prolog)
  block()
  LOOK.match("e")
  Assembler.generate(.Epilog)
}

func alloc(_ n: Character) {
  if isInTable(n) {
    abort(msg: "Duplicate variable name \(n)")
  }
  ST[n] = true
  
  var isPositive = true
  
  emit(msg: "\(n):\tDC ")
  if LOOK.cur == "=" {
    LOOK.match("=")
    if LOOK.cur == "-" {
      isPositive = false
      LOOK.match("-")
      emit(msg: "-")
    }
    emitLine(msg: "\(getNum())", isPositive)
  } else {
    emitLine(msg: "0")
  }
}

func decl() {
  LOOK.match("v")
  alloc(LOOK.getName())
  while LOOK.cur == "," {
    LOOK.getChar()
    alloc(LOOK.getName())
  }
}

func topDecl() {
  while let cur = LOOK.cur, cur != "b" {
    switch cur {
    case "v":
      decl()
    default:
      abort(msg: "Unrecognized keyword \(cur)")
    }
  }
}

/*:
 ### factor()
 Parse and translate a math factor
 */
func factor() {
  if LOOK.cur == "(" {
    LOOK.match("(")
    expression()
    LOOK.match(")")
  } else if isAlpha(LOOK.cur) {
    Assembler.generate(.LoadVar(LOOK.getName()))
  } else {
    Assembler.generate(.LoadConst(getNum()))
  }
}

/*:
 ### negFactor()
 Parse and translate a negative math factor
 */
func negFactor() {
  LOOK.match("-")
  if isDigit(LOOK.cur) {
    let num = getNum()
    Assembler.generate(.LoadConst(-num))
  } else {
    factor()
    Assembler.generate(.Negate)
  }
}

/*:
 ### firstFactor()
 Parse and translate a leading factor
 */

func firstFactor() {
  guard let cur = LOOK.cur else { return }
  switch cur {
  case "+":
    LOOK.match("+")
    factor()
  case "-":
    negFactor()
  default:
    factor()
  }
}

func prog() {
  LOOK.match("p")
  Assembler.generate(.Header)
  topDecl()
  main()
  LOOK.match(".")
}

func isInTable(_ n: Character) -> Bool {
  guard let res = ST[n] else { return false }
  return res
}

func initializeSymbolTable() {
  let allVars = (97...122).map({Character(UnicodeScalar($0))})
  allVars.map { name in
    ST[name] = false
  }
}

func initialize() -> Buffer {
  initializeSymbolTable()
  var LOOK = Buffer(idx: 0, cur: nil, input: "pva,b=123,c=-456be.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
  abort(msg: "Unexpected data after `.`")
}
