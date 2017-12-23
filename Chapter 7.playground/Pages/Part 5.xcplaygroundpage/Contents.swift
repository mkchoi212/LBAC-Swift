//: [Previous](@previous)
/*:
 # LBaC
 # Chapter VII: Lexical Scanning
 ## Part 5: Lists, Commas and Command Lines
 
 Most programs and OS's have rigid rules about how you must seperate items in a list.
 Some programs require spaces as delimiters and some require commas; and some require both!
 
 This is inexcusable since we can easily write a parser that can handle both spaces and commas
 in a flexible way.
 */

func isOperator(_ c: Character) -> Bool {
  return ["+", "-", "*", "/", "<", ">", ":", "="].contains(c)
}

func skipWhite() {
  while let c = LOOK.cur, isWhite(c) {
    LOOK.getChar()
  }
}

/*:
 ### skipComma()
 This function will skip over any number of spaces with zero or more commas embedded within a string.
 */
func skipComma() {
  skipWhite()
  
  if let c = LOOK.cur, c == "," {
    LOOK.getChar()
    skipWhite()
  }
}

func fin() {
  if let cur = LOOK.cur, cur == "\n" {
    LOOK.getChar()
  }
}

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
  } else if isOperator(c) {
    token = getOp()
  } else {
    token = String(c)
    LOOK.getChar()
  }
  skipWhite()
  return token
}

func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "coffee <= tea\ncoffe + milk  ,, sugar = latte.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()

var token: String
repeat {
  token = scan()
  print(token)
} while(token != ".")

/*:
 ### So far...
 Notice how easy the new addition of the new feature was... once again!
 
 I think this was one of the cooler chapters in the book. I don't know about you but being relieved from single character tokens felt soooo good 😍😍😍
 
 ----
 ### End of Chapter 7
 */

