import Foundation

/*:
 # LBaC
 # Part III: More Expressions
 ## Functions
 
 So far, our parser has been a "predictive parser" in that it knows what's
 going to come next by looking at the current character. This is not the case
 when we add functions.
 
 Variable names and function names obey the same rules.. so how do we tell them
 apart? Different languages to it differently but we will do what C does.
 
 `x()` will call the function `x`.
 
 We don't have a way to declare types so we can't deal with parameters. That's why
 we will have to do with an empty list for now.
 
 While at it, let's make it so that the compiler understand what white space and
 carriage returns are.
 */

let TAB: Character = "\t"
let CR: Character = "\r\n"
let addOp : [Character] = ["+", "-"]
let mulOp : [Character] = ["*", "/"]

struct Buffer {
    var idx: Int
    var cur: Character?
    let input: String
}

extension Buffer {
    init() {
        idx = 0
        input = readLine()!
    }
    
    mutating func getChar() {
        let i = input.index(input.startIndex, offsetBy: idx)
        
        if i == input.endIndex {
            cur = nil
        } else {
            cur = input[i]
            idx += 1
        }
    }
}

func error(msg: String) {
    print("Error: \(msg).")
}

func abort(msg: String) {
    error(msg: msg)
    exit(EXIT_FAILURE)
}

func expected(_ s: String) {
    abort(msg: "\(s) expected")
}

func emit(msg: String) {
    print("\(TAB) \(msg)", separator: "", terminator: "")
}

func emitLine(msg: String) {
    print("\(TAB) \(msg)")
}

func match(_ c: Character) {
    if LOOK.cur == c {
        LOOK.getChar()
    } else {
        expected("\(c)")
    }
}

func isAlpha(_ c: Character?) -> Bool {
    if let c = c, "a"..."z" ~= c || "A"..."Z" ~= c {
        return true
    } else {
        return false
    }
}

func isDigit(_ c: Character?) -> Bool {
    if let c = c, "0"..."9" ~= c {
        return true
    } else {
        return false
    }
}
func getName() -> Character {
    let c = LOOK.cur
    if !isAlpha(c) {
        expected("Name")
    }
    let upper = String(c!).uppercased().characters.first!
    LOOK.getChar()
    return upper
}

func getNum() -> Character {
    let num = LOOK.cur
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    LOOK.getChar()
    return num!
}

func indent() {
    guard let cur = LOOK.cur else { return }
    let name = getName()
    if cur == "(" {
        match("(")
        match(")")
        emitLine(msg: "BSR \(name)")
    } else {
        emitLine(msg: "MOVE \(name)(PC),D0")
    }
}

/*:
 ## Two possibilities for the `isAlpha` case
 Let's move var / func processing into a seperate function
 `indent()`.
 
 When `factor()` finds a letter, it doesn't know if it's a
 var or a func. It passes it to `indent()` and let's it figure it out.
 Very simple but powerful concept 💡
 */

func factor() {
    guard let cur = LOOK.cur else { return }
    
    if cur == "(" {
        match("(")
        expression()
        match(")")
    } else if isAlpha(cur) {
        emitLine(msg: "MOVE \(getName())(PC),D0")
    }
    else {
        emitLine(msg: "MOVE #\(getNum()),D0")
    }
}

func multiply() {
    match("*")
    factor()
    emitLine(msg: "MULS (SP)+,D1")
}

func divide() {
    match("/")
    factor()
    emitLine(msg: "MULS (SP)+,DO")
    emitLine(msg: "DIVS D1, D0")
}

func add() {
    match("+")
    term()
    emitLine(msg: "ADD (SP)+,D0")
}

func subtract() {
    match("-")
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
    
    // Place imaginary 0 by clearing D0 register
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
    var LOOK = Buffer(idx: 0, cur: nil, input: "1+2 +3+4")
    LOOK.getChar()
    return LOOK
}

/// Main Program
var LOOK = initialize()
expression()

/*:
 ## Previously white space was considered as a terminator
 Flagging this will do for now
 */
if let cur = LOOK.cur, cur != CR {
    expected("Newline")
}
