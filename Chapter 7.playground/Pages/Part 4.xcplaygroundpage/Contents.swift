//: [Previous](@previous)
/*:
 # LBaC
 # Chapter VII: Lexical Scanning
 ## Part 4: Operators
 We currently have support for tokens over multiple lines! But what fun is it if we can't calculate stuff??
 
 Let's handle operators the same way we handle other token to make this happen.
 */

/*:
 ### isOperator()
 This function will be used to recognize the legal operators.be
 
 Notice not all possible operators are in this list; i.e. `<=`
 
 > The list only contains characters that can appear in **multi-character operators**; i.e. `<=`
 */
func isOperator(_ c: Character) -> Bool {
  return ["+", "-", "*", "/", "<", ">", ":", "="].contains(c)
}

func isAlpha(_ c: Character) -> Bool {
  if "a"..."z" ~= c || "A"..."Z" ~= c {
    return true
  } else {
    return false
  }
}

func isDigit(_ c: Character) -> Bool {
  if "0"..."9" ~= c {
    return true
  } else {
    return false
  }
}

func skipWhite() {
  while let c = LOOK.cur, isWhite(c) {
    LOOK.getChar()
  }
}

func fin() {
  if let cur = LOOK.cur, cur == "\n" {
    LOOK.getChar()
  }
}

/*:
 ### getOp()
 Recognize and get the operators
 */
func getOp() -> String{
  var token = ""
  if let c = LOOK.cur, !isOperator(c) {
    expected("Operator")
  }
  
  while let c = LOOK.cur, isOperator(c) {
    token += String(c)
    LOOK.getChar()
  }
  skipWhite()
  return token
}

/*:
 ### scan()
 Our lexer now checks for `isOperator` and calls `getOp` when it sees one.
 */
func scan() -> String {
  var token = ""
  guard let c = LOOK.cur else { fatalError("EOF") }
  
  while let c = LOOK.cur, c == LF {
    fin()
  }
  
  if isAlpha(c) {
    token = LOOK.getName()
  } else if isDigit(c){
    token = LOOK.getNum()
  } else if isOperator(c) {   // Do we have a operator???
    token = getOp()
  } else {
    token = String(c)
    LOOK.getChar()
  }
  skipWhite()
  return token
}

/*:
 ### So far...
 Now, fragments are neatly broken up into individual tokens! This looks like a proper lexer now!  🎊🎊🎊
 
 Try some inputs of your own!
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "coffee <= tea\ncoffe + milk = latte.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()

var token: String
repeat {
  token = scan()
  print(token)
} while(token != ".")
//: [Next](@next)
