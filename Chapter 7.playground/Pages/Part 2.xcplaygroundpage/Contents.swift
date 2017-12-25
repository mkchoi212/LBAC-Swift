//: [Previous](@previous)
/*:
 # LBaC
 # Chapter VII: Lexical Scanning
 ## Part 2: White Space
 In this part, we will add support for whitespaces before we go any further.
 
 Also, we will recognize a carriage return (newline) as a terminating character for now.
 */

let LF = "\n"
let whiteChars: [Character] = [" ", TAB]

/*:
 ### isWhite() & skipWhite()
 These two functions have been copied from `Chapter 03/Part 4.playground`
 
 > Notice that they have been added to the end of `getName` and `getNum`
 */
func isWhite(_ c: Character) -> Bool {
  return whiteChars.contains(c)
}

func skipWhite() {
  while let c = LOOK.cur, isWhite(c) {
    LOOK.getChar()
  }
}

func getName() -> String {
  var token = ""
  if let c = LOOK.cur, !isAlpha(c) {
    expected("Name")
  }
  
  while let c = LOOK.cur, isAlphaNum(c) {
    token += String(c).uppercased()
    LOOK.getChar()
  }
  // Skip remaining whitespace
  skipWhite()
  return token
}

func getNum() -> String {
  var token = ""
  if let c = LOOK.cur, !isDigit(c) {
    expected("Integer")
  }
  
  while let c = LOOK.cur, isDigit(c) {
    token += String(c)
    LOOK.getChar()
  }
  // Skip remaining whitespace
  skipWhite()
  return token
}

/*:
 ### scan()
 This is the lexical scanner that is wrapping it all
 */
func scan() -> String {
  var token = ""
  guard let c = LOOK.cur else { fatalError("EOF") }
  
  if isAlpha(c) {
    token = getName()
  } else if isDigit(c){
    token = getNum()
  } else {
    token = String(c)
    LOOK.getChar()
  }
  skipWhite()
  return token
}

func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "3123  abc    xyz\n")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()

/*:
 ### Support for multiple tokens
 Notice how the loop continues until it sees a line-feed (newline)
 */
var token: String
repeat {
  token = scan()
  print(token)
} while(token != LF)

/*:
 ## State Machines
 Before we go on, let's briefly talk about state machines.
 
 Did you know `getName` is a state machine? The state represented in `getName` is the current position in the code.
 
 In fact, if we look at our compiler in its entirety, what we have is a gigantic state machine. Take for example, things begin in the start of the state and end when a non-alphanumeric character is found. Otherwise, the "machine" will continue looping until a terminating delimiter is found.
 
 Note that our position in the code we are parsing is entirely dependent on the past history of input characters. At that point, the only action to be taken depends on the current state plus what `LOOK.cur` is. This is what makes our code a **state machine**.
 
 We didn't talk about it but `skipWhite` and `getNum` are also state machines; just like their parent function `scan`.
 
 > Keep in mind that **little machines make up big machines.**
 */
//: [Next](@next)
