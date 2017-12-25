//: [Previous](@previous)
/*:
 # LBaC
 # Chapter X: Introducing "TINY"
 ## Part 7: Executable Statements I
 Our compiler can declare and initialize things but we have still yet to generate executable code!
 
 But believe it or not, we are REALLY close to having a usable language. **All we need is the executable code that has to go into the main program**. But all that code is just assignment statements and control statements; stuff we have all done before 😎
 
 
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

func header() {
  emitLine(msg: "WARMST\tEQU $A01E")
}

func prolog() {
  postLabel("MAIN")
}

func epilog() {
  emitLine(msg: "DC WARMST")
  emitLine(msg: "END MAIN")
}

/*:
 ### assignment()
 We'll leave it as a stub for now
 */
func assignment() {
  LOOK.getChar()
}

/*:
 ### block()
 We will start by assuing that a block is just a series of assignment statements.
 
 > Still doesn't generate any code though.. Just eats chars until `e` || `END`
 */
func block() {
  while LOOK.cur != "e" {
    assignment()
  }
}

/*:
 > `block()` has been added to parse the statement block within the main program
 */
func main() {
  LOOK.match("b")
  prolog()
  block()         // NEW!
  LOOK.match("e")
  epilog()
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

func prog() {
  LOOK.match("p")
  header()
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

//: [Next](@next)
