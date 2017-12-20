//: [Previous](@previous)
/*:
 # LBaC
 # Chapter II: Expression Parsing
 ## Part 4: Parentheses
 
 We need parentheses to be able to maximize our ability to express operator precedence.
 
 The key to incorporate `(` and `)` into our parser is to realize that
 **no matter how complicated an expression may be, it's no
 different from a simple factor.** 😎
 */

/*:
 ### factor
 This is where recursion comes in since an `expression` ca`n contain a `factor`, which contins another `expression` which contains a `factor` and so on.... you get the idea
 */
let addOp : [Character] = ["+", "-"]
let mulOp : [Character] = ["*", "/"]

func factor() {
    guard let cur = LOOK.cur else { return }
    
    if cur == "(" {
        LOOK.match("(")
        expression()        // The Recursion ↩️↩️↩️
        LOOK.match(")")
    } else {
        emitLine(msg: "MOVE #\(LOOK.getNum()),D0")
    }
}

func expression() {
    // Which calls `term` again...
    term()
    
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

func term() {
    // Which calls `factor` again...
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

func multiply() {
    LOOK.match("*")
    factor()
    emitLine(msg: "MULS (SP)+,D1")
}

func divide() {
    LOOK.match("/")
    factor()
    emitLine(msg: "MULS (SP)+,DO")
    emitLine(msg: "DIVS D1, D0")
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

/*:
 ## So far...
 Notice in the console that the `add` operation is done before the `MULS` operation!
 
 Try bunch of other expressions to play around!

 > While you are at it, try setting the `input` as `-1` and see what happens; hint... it should crash 😳😳😳
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "1*(2+1)")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
expression()

//: [Next](@next)
