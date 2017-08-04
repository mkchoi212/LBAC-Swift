import Foundation

/*:
 # LBaC 
 # Part II: Expression Parsing
 ## Unary Minus
 
 So using `-1` as the `input` crashed the compiler. How do we fix this?
 Ok, so we have a parser that looks like it's working but using `-1` as the input
 will crash the program in the previous.
 
 There are many ways to fix this but the easiest is to put an **imaginary zero**
 in front of expressions like `+3` so that it becomes `0+3`.
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

func factor() {
    guard let cur = LOOK.cur else { return }
    
    if cur == "(" {
        match("(")
        expression()
        match(")")
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

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "-1")
    LOOK.getChar()
    return LOOK
}

/// Main Program
var LOOK = initialize()
expression()

/*:
 # Notes on optimization
 Not that difficult... there are two approaches to it
 1. **Fix the code after it's generated**
 
     Concept of "peephole" optimization. Idea is that since we know
     what kind of code the compiler will generate and which ones are bad,
     we can look at the produced code and replace the bad ones with good code.
 
     This is basically bunch of macro expansions - in reerse - and is just
     straight up pattern-matching; lots of patterns. It's called "peephole" op since
     it llooks for small group of instructions at a time.
 
     Has dramatic effect to the quality of code with little effort. But *speed, size, and
     complexity grows* due to all those combination calls.
 
 2. **Generate good code in the first place**
 
     This makes us look at special cases **BEFORE** we emit them. For example, before we
     add a zero to a number, we could emit a `CLR` instead of a `load` and or do nothing.
 
     Don't think too much about this right now. If we want to tighten up the generated code,
     we can always go back to it once we have a *working compiler!*
 
 LBaC author suggests an additional idea to faster code; *don't use CPU stacks*. 680000 has 8
 data registers and we could use them as a **privately managed stack** for expressions up to
 8 data points. If we need more than 8 levels of stack, we can let the stack *spill over* to the
 CPU stack to gain more space.
 
 Apparentlly the author tested this and works well!!
 */
