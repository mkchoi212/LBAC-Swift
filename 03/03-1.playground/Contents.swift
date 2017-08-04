import Foundation

/*:
 # LBaC
 # Part III: More Expressions
 ## Variables
 
 Most expressions in real life involve variables; eg `b * b + 4 * a * c`
 and no parser is any good without being able to deal with them.
 
 Currenlty, only 2 factors are allowed in our parser; integer constatns
 and expressions within parentheses. Turns out variable is just another kind
 of factor.
 
 So, instead of loading a number to a register, we load a variable into it.
 */

let TAB: Character = "\t"
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

/*:
 ## Variable parsing is added with `isAlpha`
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
    emitLine(msg: "DIVS D1,D0")
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
    var LOOK = Buffer(idx: 0, cur: nil, input: "a+1")
    LOOK.getChar()
    return LOOK
}

/// Main Program
var LOOK = initialize()
expression()
