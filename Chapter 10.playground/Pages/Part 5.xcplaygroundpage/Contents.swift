//: [Previous](@previous)
/*:
 # LBaC
 # Chapter X: Introducing "TINY"
 ## Part 5: Initializers
 
 Did you know Pascal doesn't allow you to initialize data items in its declaration? Doesn't that bother you?
 
 Well, this is our language and so let's fix that here 😎
 */

/*:
 ### getNum()
 Now supports multi-digit integers!
 */
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
 Six added lines and now you can initialize variables with **signed and unsigned integers** 🎉🎉🎉
 */
func alloc(_ n: Character) {
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
 ### So far...
 
 Things are starting to look real! The program doesn't really do anything useful but still!
 */
func initialize() -> Buffer {
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
