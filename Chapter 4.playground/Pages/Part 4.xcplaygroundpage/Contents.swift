//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IV: Interpreters
 ## Part 4: Variables
 
 In the compiler, all we had to do was to just issue the names to the asembler and let it take care of allocating storage for them.
 Here, **we need to be able to fetch the values when we need them.
 So, what we need is a storage mechanism for the variables.** We will use Swift's `Dictionary` for that.
 
 And just like Tiny BASIC, we will have only **26 possible variables**; one for each letter in the alphabet (lower-case)
 
 > Because of this restriction, you will see some force unwrapping being done through out the code with `!`.
 >
 > I apologize in advance for such a abomination 🙁
 */

/*:
 ### table
 This variable will be responsible for storing the values of all variables within the program.
 
 But first, we must initialize the dictionary with every single letter in the alphabet *(lowercase)* as the keys and zero as the default values.
 */
var table: [Character:Int] = [:]
/*:

 */
func initTable() {
  for val in UnicodeScalar("a").value...UnicodeScalar("z").value {
    table[String(UnicodeScalar(val)!).first!] = 0
  }
}


/*:
 ### factor()
 
 A single if-statement has been added to check if the given `factor` is a variable or not.
 */
func factor() -> Int {
  let value: Int
  
  if let cur = LOOK.cur, cur == "(" {
    LOOK.match("(")
    value = expression()
    LOOK.match(")")
  } else if isAlpha(LOOK.cur) {
    value = table[LOOK.getName()]!  // We are assuming the variable name given by the user is a letter in the alphabet!
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
 ### assignment()
 As we did previously when we built the compiler, `assignment` looks for a `=` and stores the appropriate results in the table.
 */
func assignment() -> (Character, Int) {
  let name = LOOK.getName()
  LOOK.match("=")
  let result = expression()
  table[name] = result
  return (name, result)
}

/*:
 ### So far...
 Our interpreter supports parenthesis, operator-precedence and assignments! Whoop 😄
 > Try other inputs to the program. It's basically like a mini-calculator!
 */
func initialize() -> Buffer {
  initTable()
  var LOOK = Buffer(idx: 0, cur: nil, input: "a=(60/2)+3")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
print(assignment())
//: [Next](@next)
