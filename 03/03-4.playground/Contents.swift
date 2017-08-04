import Foundation

/*:
 # LBaC
 # Part III: More Expressions
 ## Multi-Character Tokens
 
 Everything so far has been single-character tokens.
 The extension is fairly easy to do and in the process, we will
 also provide support for embedded white space. Finally! 😃
 
 > Note that this is just to show that multi-character tokens are possible.
 As we go on, we will use the single-character version to keep things
 as **simple as possible**
 
 ## Additional Notes
 Most compilers do the onput stream parsing in a seperate module called
 the **lexical scanner**. The idea is that the scanner is the one that deals
 with character input to generate tokens of the stream.
 
 We could do that here but it's much easier to just play with `getName` and
 `getNum` to get what we need.
 */

let TAB: Character = "\t"
let CR: Character = "\r\n"

let whiteChars: [Character] = [" ", TAB]
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
    if LOOK.cur != c {
        expected("\(c)")
    } else {
        LOOK.getChar()
        skipWhite()
    }
}

/*:
 ## Handling whitespaces
 The key to handling white space is to come up with a simple rule
 and enfore that rule everywhere.
 
 So far, we assumed that after each parsing action, a useful character was
 waiting to be parsed. This means that we need a routine that skips over
 the whitespaces and leave the next non-whitespace character in `LOOK.cur`
 
 We just need to fix up `getName()`, `getNum()`, `match()`, and `initialize()`
 */

/// Eat up all the whitespaces
func skipWhite() {
    while isWhite(LOOK.cur) {
        LOOK.getChar()
    }
}

func isWhite(_ c: Character?) -> Bool {
    guard let c = c else { return false }
    return whiteChars.contains(c)
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

func isAlphaNum(_ c: Character?) -> Bool {
    return isAlpha(c) || isDigit(c)
}

/*:
 ## Rules of an identifier
 1. First char must be a letter
 2. Rest has be to `isAlphaNum`
 */
func getName() -> String {
    if !isAlpha(LOOK.cur) {
        expected("Name")
    }
    
    var tokens = ""
    // Loop and gather tokens
    while let cur = LOOK.cur, isAlphaNum(cur) {
        tokens += String(cur).uppercased()
        LOOK.getChar()
    }
    
    skipWhite()
    return tokens
}

func getNum() -> String {
    if !isDigit(LOOK.cur) {
        expected("Name")
    }
    
    var value = ""
    while let cur = LOOK.cur, isDigit(cur) {
        value += String(cur)
        LOOK.getChar()
    }
    
    skipWhite()
    return value
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

func assignment() {
    let name = getName()
    match("=")
    expression()
    emitLine(msg: "LEA \(name)(PC),A0")
    emitLine(msg: "MOVE D0,(A0)")
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "foobar = 123 +      456")
    LOOK.getChar()
    skipWhite()
    return LOOK
}

/// Main Program
var LOOK = initialize()
assignment()

if let cur = LOOK.cur, cur != CR {
    expected("Newline")
}

/*:
 The parser is complete. It's got every feature we could put in a
 one-line "compiler".
 
 In the next chapter, we will continue talking about expressions
 but will also talk about interpreters as opposed to compilers.
 */
