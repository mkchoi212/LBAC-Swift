import Foundation

/*:
 # LBaC
 # Part III: More Expressions
 ## Assignment Statements
 
 Parsing an expression is not much good if we don't do anything with
 it afterwards. Let's make that possible here.
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

func factor() {
    guard let cur = LOOK.cur else { return }
    
    if cur == "(" {
        match("(")
        expression()
        match(")")
    } else if isAlpha(cur) {
        emitLine(msg: "MOVE \(getName())(PC),D0")
    } else {
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

/*:
 ## Support assignments
 Last two ASM is just a peculiarity in the 680000 that you can ignore
 */
func assignment() {
    let name = getName()
    match("=")
    expression()
    emitLine(msg: "LEA \(name)(PC),A0")
    emitLine(msg: "MOVE D0,(A0)")
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "a=3+2")
    LOOK.getChar()
    return LOOK
}

/// Main Program
/*:
 Call to `expression()` is now handled from `assignment()`
 */
var LOOK = initialize()
assignment()

if let cur = LOOK.cur, cur != CR {
    expected("Newline")
}
