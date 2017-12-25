//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IV: Interpreters
 ## Part 2 :Interpreting...
 
 We will implement many of the same things we have already done when we built the compiler in previous chapters. These include...
 
 1. `term()` to support operator-precedence and `* /` operators
 2. Allowing multi-digit inputs once again!
 */
/*:
 ### getNum()
 Let's support multi-digit numbers because we like `BigNums`!
 */
func getNum() -> Int {
  var value = 0
  
  if !isDigit(LOOK.cur) {
    expected("Integer")
  }
  
  while isDigit(LOOK.cur) {
    value = (10 * value) + Int(String(LOOK.cur!))!
    LOOK.getChar()
  }
  
  return value
}

/*:
 ### term()
 Remember `term` from previous chapters?
 
 This function is called within `expression()` in order to ensure **operator precedence!** We did the same thing in previous chapters when we built the compiler.
 */
func term() -> Int {
  var value = getNum()
  
  while let cur = LOOK.cur, mulOp.contains(cur) {
    switch cur {
    case "*":
      LOOK.match("*")
      value *= getNum()
    case "/":
      LOOK.match("/")
      value /= getNum()
    default:
      expected("* or /")
    }
  }
  
  return value
}

/*:
 ### expression()
 **Every single call to `getNum()` has been replaced with `term()`**.
 
 > Keep in mind that we are doing integer division, `1/3` will be `0`.
 */
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
      // Calls `term` instead of `getNum` now
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
 ### So far...
 With the help of `term` and some simple top-down parsing techniques, we now support operator precedence and `* /` operators!
 
 > Because of operator precedence, `12+4/4` evaluates to `13` and NOT `4`.
 */
 
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "12+4/4")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
print(">> \(expression())")

//: [Next](@next)
