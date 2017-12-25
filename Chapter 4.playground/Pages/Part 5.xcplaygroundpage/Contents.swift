//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IV: Interpreters
 ## Part 5: I/O
 
 In the last section, we were able to build a functioning interpreter!
 However, what's good if we don't have a way to read data in order write it out?
 
 What we need is **I/O**.
 
 We will declare two special operators to handle I/O in our interpreter.
 - `?`  indicates a `read`
 - `!`  indicates a `write`
 */

var table: [Character:Int] = [:]

func initTable() {
  for val in UnicodeScalar("a").value...UnicodeScalar("z").value {
    table[String(UnicodeScalar(val)!).first!] = 0
  }
}

/*:
 ### newline()
 This will allow us to handle multiple lines.
 It recognizes a newline and skips over it to proceed to the next line
 */
func newline() {
  if let cur = LOOK.cur, cur == "\n" {
    LOOK.getChar()
  }
}

func assignment() {
  let name = LOOK.getName()
  LOOK.match("=")
  table[name] = expression()
}

func factor() -> Int {
  let value: Int
  
  if let cur = LOOK.cur, cur == "(" {
    LOOK.match("(")
    value = expression()
    LOOK.match(")")
  } else if isAlpha(LOOK.cur) {
    value = table[LOOK.getName()]!
  } else {
    value = LOOK.getNum()
  }

  return value
}

func term() -> Int {
  var value = factor()
  
  while let cur = LOOK.cur, mulOp.contains(cur) {
    switch cur {
    case "*":
      LOOK.match("*")
      value *= factor()
    case "/":
      LOOK.match("/")
      value /= factor()
    default:
      expected("* or /")
    }
  }
  
  return value
}

func expression() -> Int {
  var value: Int
  
  if let cur = LOOK.cur, addOp.contains(cur) {
    value = 0
  } else {
    value = term()
  }
  
  while let cur = LOOK.cur, addOp.contains(cur) {
    switch cur {
    case "+":
      LOOK.match("+")
      value += term()
    case "-":
      LOOK.match("-")
      value -= term()
    default:
      expected("+ or -")
    }
  }
  
  return value
}

/*:
 ### input()
 In a real interpreter, we would **read** an input from the user.
 But since we are in a Playground, we will just read from the static string like we have been doing.
 
 ```
 ?z3 -> READ 3 into VAR z
 ```
 */
func input() {
  LOOK.match("?")
  
  let variable = LOOK.getName()
  if let cur = LOOK.cur {
    table[variable] = Int(String(cur))
    LOOK.getChar()
  }
}

/*:
 ### output()
 To make things look pretty, we are going to print the variables in the format `VAR = VAL`
 
 ```
 !a -> PRINT VAR a
 ```
 */
func output() {
  LOOK.match("!")
  print("\(LOOK.cur!) = \(table[LOOK.getName()]!)")
}

/*:
 The example input can be translated into following lines of code
 ```
 a = (60/2)+3
 b = 9
 print a
 print b
 z = 3
 print z
 ```
 */
func initialize() -> Buffer {
  initTable()
  var LOOK = Buffer(idx: 0, cur: nil, input: "a=(60/2)+3\n" +
                                             "b=9\n"        +
                                             "!a!b\n"       +
                                             "?z3!z.")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()

while let cur = LOOK.cur, cur != "." {
  // Notice the new cases
  switch cur {
  case "?":
    input()
  case "!":
    output()
  default:
    assignment()
  }
  newline()
}

/*:
 # Overview
 
 🎊🎊🎊 Congratulations, we built a somewhat working interpreter 🎉🎉🎉
 
 It's **features** are
 - Three kinds of program statements
 - Support for 26 variables
 - I/O statements
 
 but **lacks**
 - Control statements *(covered in next chapter)*
 - Subroutines *(covered in next..next chapter)*
 - Program editing function *(❗not covered cause slightly complicated)*
 
 ---
 ### End of Chapter 4 👋
 */
