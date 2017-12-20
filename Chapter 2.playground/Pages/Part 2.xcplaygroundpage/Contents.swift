//: [Previous](@previous)

/*:
 # LBaC
 # Chapter II: Expression Parsing
 ## Part 2: Binary / General Expressions
 
 Parsing a single digit doesn't do much. So, let's make our compiler handle binary expressions;
 expressions like `1+2` and `4-3`.
 
 Also, take a look at the object code. Notice that the generated code is **NOT**
 what humans would write (it's inefficient)
 > We will ignore optimization and just concentrate on generating code for now
 */

/*:
 ### add(), subtract()
 Generates appropriate code for respective operations
 */
func add() {
    LOOK.match("+")
    term()
    emitLine(msg: "ADD D1, D0")
}

func subtract() {
    LOOK.match("-")
    term()
    emitLine(msg: "SUB D1, D0")
    emitLine(msg: "NEG D0")
}

func term() {
    emitLine(msg: "MOVE #\(LOOK.getNum()),D0")
}

/*:
 ### expression()
 Expression now recognizes and distinguishes between a `+` and a `-` and generates the appropriate code.
 */
let addOp : [Character] = ["+", "-"]

func expression() {
    term()
    
    while let cur = LOOK.cur, addOp.contains(cur) {
        emitLine(msg: "MOVE D0,D1")
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
 Try any combination of signle digits, seperated by a `+` or `-`.
 > Try some expressions with errors and see what happens!
 ```
 3-a
 ```
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3-1")
    LOOK.getChar()
    return LOOK
}

/// Main Program
var LOOK = initialize()
expression()

//: [Next](@next)
