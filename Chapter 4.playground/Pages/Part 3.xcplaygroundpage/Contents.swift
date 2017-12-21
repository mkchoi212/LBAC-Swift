//: [Previous](@previous)
/*:
 # LBaC
 # Chapter IV: Interpreters
 ## Part 3: Interpreting... continued
 
 Finally, we will implement `factor()` to support for parenthesis.
 We are almost there on making a useful interpreter!
 
 > Check out the end for a little philosophy session 🤔
 */

/*:
 ### factor()
 This function will now allow for factors and parenthesis!
 
 We will hold off a bit longer on the variable names.
 */
func factor() -> Int {
  let value: Int
  
  if let cur = LOOK.cur, cur == "(" {
    LOOK.match("(")
    value = expression()    // Remember the recursive call to `expression` here?
    LOOK.match(")")
  } else {
    value = LOOK.getNum()
  }
  
  return value
}

/*:
 ### term()
 Calls to `getNum()` has been changed to `factor()` for the recursion!
 
 > If you forgot how parsing for parenthesis works, check out **Part 4 of Chapter 2**!
 */
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
 ### So far...
 We now support parenthesis.. yay!
 */
func initialize() -> Buffer {
  var LOOK = Buffer(idx: 0, cur: nil, input: "(60+3)/3")
  LOOK.getChar()
  return LOOK
}

var LOOK = initialize()
print(">> \(expression())")

/*:
 ## A Little Philosophy 📖
 
 > You can skip this but this little bit will help you understand operator precedence in depth.
 
 In the early days of compiler technology, people really stuggled trying to
 deal with things like opeartor precedence. People used 1, 2, 3 stacks with
 compiler precedence values that needed to be compared which then envolved more
 complicated steps. Other methods include using a parse tree, which is favored
 by many compiler textbooks.
 
 Anyways, we are doing similar things in our interpreter but we didn't use any stacks or trees.
 So, where are the stacks and the trees?
 
 **The answer is that the structures are implicit, not explicit.**
 
 Everytime Swift calls a `term()`, `expression()` or any subroutine, the return address is
 pushed onto the CPU stack. At the end, it's popped off and control is transferred.
 
 In other words, everything has been so simple because we have been using the resources
 provided by the language. Trees and stacks are all there but just hidden behind all the
 recursives calls made within Swift.
 
 ## TL;DR
 > **The lesson:** things can be easy when you do them right.
 >
 > **The warning:** take a long, hard look at what you're doing
 */
//: [Next](@next)
