//: [Previous](@previous)
import Foundation
/*:
 # LBaC
 # Chapter X: Introducing "TINY"
 ## Part 6: The Symbol Table
 
 So out compiler doesn't do anything to record a variable when we declare it...
 This makes code like this legal...
 ```
 PROGRAM
 VAR a
 VAR a
 VAR a
 ```
 
 The compiler will then declare three different `a`'s at three different memory locations... 😕
 Also, when we start referencing variables, the compiler will try to refer to variables that don't exist. Then the ASSEMBLER will throw a fit... which is NOT what we want.
 
 So.. **it seems like we are going to need a symbol table to check to keep track of variables.**
 
 */

/*:
 ### THE SYMBOL TABLE
 Our humble `ST` will keep track of which variable - `Character` - has been declared or not.
 */
var ST : [Character : Bool] = [:]
let TAB : Character = "\t"
let LF = "\n"
let whiteChars: [Character] = [" ", TAB]

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

func main() {
  match("b")
  prolog()
  match("e")
  epilog()
}

/*:
 ### alloc()
 Now takes advantage of the **symbol table** to check for **duplicate variable names** 🎉🎉🎉
 */
func alloc(_ n: Character) {
  if isInTable(n) {
    abort(msg: "Duplicate variable name \(n)")
  }
  ST[n] = true
  
  var isPositive = true
  
  emit(msg: "\(n):\tDC ")
  if LOOK.cur == "=" {
    match("=")
    if LOOK.cur == "-" {
      isPositive = false
      match("-")
      emit(msg: "-")
    }
    emitLine(msg: "\(getNum())", isPositive)
  } else {
    emitLine(msg: "0")
  }
}

func decl() {
  match("v")
  alloc(getName())
  while LOOK.cur == "," {
    LOOK.getChar()
    alloc(getName())
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
  match("p")
  header()
  topDecl()
  main()
  match(".")
}

/*:
 ### isInTable()
 Check if variable has been declared by checking the symbol table
 - `false` -> variable **IS NOT DECLARED**
 - `true`  -> variable **IS DECLARED** and is under use
 */
func isInTable(_ n: Character) -> Bool {
  guard let res = ST[n] else { return false }
  return res
}

/*:
 ### initializeSymbolTable()
 Since only one-character variables are allowed, we can easily initialize a symbol table.
 */
func initializeSymbolTable() {
  // Make an array of chars from `a` to `z`
  let allVars = (97...122).map({Character(UnicodeScalar($0))})
  // Initialize all variables to `false` in table
  allVars.map { name in
    ST[name] = false
  }
}
/*:
 ### So far...
 The compiler can now detect duplicate variables!
 
 Here, we are attempting to declare the varaible `b` twice. The compiler catches the error and warns us about the duplicate variable name 😄😄😄
 */
func initialize() -> Buffer {
  initializeSymbolTable()
  var LOOK = Buffer(idx: 0, cur: nil, input: "pva,b=123,b=-456be.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
  abort(msg: "Unexpected data after `.`")
}
//: [Next](@next)
