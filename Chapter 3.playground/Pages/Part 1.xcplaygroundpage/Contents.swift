/*:
 # LBaC
 # Chapter III: More Expressions
 ## Part 1: Variables
 
 So there are two BIG restrictions to our amazing compiler
 1. No variables are allowed. Just numbers
 2. Numbers are limited to single digits
 
 And most people want to use variables and big numbers in their programs...
 
 Remember that only two kinds of `factor`s are allowed in our parser; integer constants and expressions within parentheses. So all we need to do is add support for variables!
 */

/*:
 ### factor()
 factor now checks if the look-ahead character `cur`, `isAlpha`. If `isAlpha` returns `true`, we have ourselves a variable!
 */
func factor() {
    guard let cur = LOOK.cur else { return }
    
    if cur == "(" {
        LOOK.match("(")
        expression()
        LOOK.match(")")
    } else if isAlpha(cur) {            // Check if variable!
        emitLine(msg: "MOVE \(LOOK.getName())(PC),D0")
    }
    else {
        emitLine(msg: "MOVE #\(LOOK.getNum()),D0")
    }
}

func multiply() {
    LOOK.match("*")
    factor()
    emitLine(msg: "MULS (SP)+,D1")
}

func divide() {
    LOOK.match("/")
    factor()
    emitLine(msg: "MULS (SP)+,DO")
    emitLine(msg: "DIVS D1,D0")
}

func add() {
    LOOK.match("+")
    term()
    emitLine(msg: "ADD (SP)+,D0")
}

func subtract() {
    LOOK.match("-")
    term()
    emitLine(msg: "SUB (SP)+,D0")
    emitLine(msg: "NEG D0")
}

func term() {
    factor()
    
    while let cur = LOOK.cur, mulOp.contains(cur) {
        emitLine(msg: "MOVE D0,-(SP)")
        switch String(cur) {
        case "*":
            multiply()
        case "/":
            divide()
        default:
            expected("* or /")
        }
    }
}

func expression() {
    guard let cur = LOOK.cur else { return }

    if addOp.contains(cur) {
        emitLine(msg: "CLR D0")
    } else {
        term()
    }
    
    while let cur = LOOK.cur, addOp.contains(cur) {
        emitLine(msg: "MOVE D0,-(SP)")
        switch String(cur) {
        case "+":
            add()
        case "-":
            subtract()
        default:
            expected("+ or -")
        }
    }
}

/*:
 ## So far...
 Our parser supports variables now 😍. I mean... variables don't do anything right now but they exist in the memory space of the code generated!
 
 > At this point, I hope you realize how easy it is to add features to the parser.
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "a+1")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
expression()
//: [Next](@next)
