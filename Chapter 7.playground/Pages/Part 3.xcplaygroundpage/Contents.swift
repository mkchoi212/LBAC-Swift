//: [Previous](@previous)
/*:
 # LBaC
 # Chapter VII: Lexical Scanning
 ## Part 3: New Lines
 
 The simplest way to handle multiple lines in our scanner is to **treat newlines as white spaces**.
 
 By the way, this is how C does it with their `isWhite` function.
 */

func skipWhite() {
  while let c = LOOK.cur, isWhite(c) {
    LOOK.getChar()
  }
}

/*:
 ### fin()
 This same function was used previously in chapter 6 to eat up newlines.
 */
func fin() {
  if let cur = LOOK.cur, cur == "\n" {
    LOOK.getChar()
  }
}

/*:
 ### scan()
 Because we want our language to be free field, newlines should be transparent.
 `scan` now eats up all line feeds with `fin`.
 
 > Play around with different arrangments to see how you like them. If you want a line-oriented
 language's behavior - like FORTRAN/BASIC/PYTHON - you will need `scan` to return line feeds as tokens
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
  } else {
    token = String(c)
    LOOK.getChar()
  }
  skipWhite()
  return token
}

func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "\n congratulations\n\n work so hard\nwe forgot how to vacationnnnn.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()

var token: String

/*:
 ### So far...
 Now, we can scan multiple tokens over multiple lines!
 
 Notice how we are using most of the same principles we have covered in previous chapters!
 > Since we will never face a carriage return, the terminating character is now a `.` - a dot
 */
repeat {
  token = scan()
  print(token)
} while(token != ".")
//: [Next](@next)
