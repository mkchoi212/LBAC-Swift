import Foundation

/*:
 # LBaC 
 # Part II: Expression Parsing
 ## Binary / General Expressions
 
 Parsing a single digit doesn't do much. So, let's make our compiler handle binary expressions;
 expressions like 1+2 and 4-3.
 
 To do this, we need a NEW procedure that recognizes numbers and stores that in one place and
 another procedure that recognizes + and - signs to generate the correct code.
 
 Try some obvious errors and see if the compiler catches them!
 
 Also, take a look at the object code. Notice that the generated code is **NOT** 
 what humans would write (it's inefficient)
 > NOTE: We will ignore optimization and just concentrate on generating code throughout LBaC
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

func add() {
    match("+")
    term()
    emitLine(msg: "ADD D1, D0")
}

func subtract() {
    match("-")
    term()
    emitLine(msg: "SUB D1, D0")
    emitLine(msg: "NEG D0")
}

func term() {
    emitLine(msg: "MOVE #\(getNum()),D0")
}

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

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3+2")
    LOOK.getChar()
    return LOOK
}

/// Main Program
var LOOK = initialize()
expression()
