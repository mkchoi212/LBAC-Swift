//: [Previous](@previous)
/*:
 # LBaC
 # Chapter III: More Expressions
 ## Part 2: Functions
 
 So far, our parser has been a *"predictive parser"* in that it knows what's going to come next by looking at the current character.
 But this isn't going to work when we want to add functions.
 
 Variable names and function names obey the same rules.. so how do we tell them apart?
 Different languages to it differently but we will do what C does.
 
 ```
 a() -> this is a function
 a   -> this is a varaible
 ```
 > Remember how we don't have a way to declare types? Because of this, **no function parameters will be allowed; for now.**

 */

/*:
 ### factor()
 Now there are **TWO** possibilities for the `isAlpha` case
 1. Variable
 2. Function
 
 To make things more readable, let's move var / func processing into a seperate function `indent()`.
 
 When `factor()` finds a letter, it now passes it to `indent()` for it to figure it out.
 This is a very simple but very powerful concept 💡
 */

func factor() {
    guard let cur = LOOK.cur else { return }
    
    if cur == "(" {
        LOOK.match("(")
        expression()
        LOOK.match(")")
    } else if isAlpha(cur) {
        emitLine(msg: "MOVE \(LOOK.getName())(PC),D0")
    }
    else {
        emitLine(msg: "MOVE #\(LOOK.getNum()),D0")
    }
}

/*:
 ### indent()
 This function looks for `()` to figure out if whatever `factor` gave it is a `function` or a `variable`.
 ```
 a() -> this is a function
 a   -> this is a varaible
 ```
 */
func indent() {
    guard let cur = LOOK.cur else { return }
    let name = LOOK.getName()
    if cur == "(" {
        // 👀 function!
        LOOK.match("(")
        LOOK.match(")")
        emitLine(msg: "BSR \(name)")
    } else {
        // 👀 variable!
        emitLine(msg: "MOVE \(name)(PC),D0")
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

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "1+2+3+4\r\n")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
expression()

/*:
 ### EOF
 We haven't told our compiler what our language's end-of-line looks like.
 
 To solve this, we will let it know that an expression should always end with a carriage return - `CR`.
 */
let CR: Character = "\r\n"
if let cur = LOOK.cur, cur != CR {
    print(cur)
    expected("Newline")
}

//: [Next](@next)
