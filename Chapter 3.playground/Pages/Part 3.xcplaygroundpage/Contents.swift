//: [Previous](@previous)
/*:
 # LBaC
 # Chapter III: More Expressions
 ## Part 3: Assignment Statements
 
 Parsing an expression is not much good if we don't do anything with
 it afterwards. Let's make that possible here.
 */

func indent() {
    guard let cur = LOOK.cur else { return }
    let name = LOOK.getName()
    if cur == "(" {
        LOOK.match("(")
        LOOK.match(")")
        emitLine(msg: "BSR \(name)")
    } else {
        emitLine(msg: "MOVE \(name)(PC),D0")
    }
}

func factor() {
    guard let cur = LOOK.cur else { return }
    
    if cur == "(" {
        LOOK.match("(")
        expression()
        LOOK.match(")")
    } else if isAlpha(cur) {
        emitLine(msg: "MOVE \(LOOK.getName())(PC),D0")
    } else {
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

/*:
 ### assignment()
 Expressions usually appeart in assingment statments in the form
 ```
 <Variable> = <Expression>
 ```
 >
 */
func assignment() {
    let name = LOOK.getName()
    LOOK.match("=")
    expression()
    
    // You can ignore the last two code generation lines
    // They are bi-product of a peculiarity in the 680000.
    emitLine(msg: "LEA \(name)(PC),A0")
    emitLine(msg: "MOVE D0,(A0)")
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "a=3+2")
    LOOK.getChar()
    return LOOK
}

/*:
  > Call to `expression()` is now handled by `assignment()`
 */
var LOOK = initialize()
assignment()

if let cur = LOOK.cur, cur != CR {
    expected("Newline")
}


/*:
 ## So far...
 
 We can now compile assignment statements 🎉🎉🎉
 
 If those statements are the only kind of statements supported in our language, all we'd have to do is put it in a loop to make a fully-fledged compiler!
 But of course, we still have to deal with control statements; `if` and loops. But there is no need to worry. Control constructs are much easier than what we have been doing so far 😌
 */
//: [Next](@next)
