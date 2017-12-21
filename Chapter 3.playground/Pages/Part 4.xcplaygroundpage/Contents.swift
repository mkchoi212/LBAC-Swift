//: [Previous](@previous)
/*:
 # LBaC
 # Chapter III: More Expressions
 ## Part 4: Multi-Character Tokens
 
 Everything so far has been single-character tokens.
 The extension to multi-character tokens is fairly easy to do and in the process, we will also provide support for embedded white-space.
 Finally! 😃
 
 > Note that this is just to show that multi-character tokens are possible.
 >
 > As we go on, we will use the single-character version to keep things
 as **simple as possible**
 
 ## Additional Notes
 Most compilers do their input stream parsing in a seperate module called the **lexical scanner**.
 The idea is that the scanner is the part of the compiler responsible for dealing with character input to generating tokens of the stream.
 
 We could do that here but it's much easier to just play with `getName` and `getNum` to get what we need.
 */

/*:
 ### skipWhite()
 The key to handling white space is to come up with a *simple rule and enfore that rule everywhere.*
 
 So far, we assumed that after each parsing action, a useful character was
 waiting to be parsed. This means that we need a routine that skips over
 the whitespaces and leaves the next non-whitespace character in `LOOK.cur`
 */
func skipWhite() {
    while isWhite(LOOK.cur) {
        LOOK.getChar()
    }
}

let whiteChars: [Character] = [" ", TAB]

func isWhite(_ c: Character?) -> Bool {
    guard let c = c else { return false }
    return whiteChars.contains(c)
}

/*:
 ### match()
 `match` now calls `skipWhite` every time it advances a character
 */
func match(_ c: Character) {
    if LOOK.cur != c {
        expected("\(c)")
    } else {
        LOOK.getChar()
        // Skip remaining white-spaces after matching
        skipWhite()
    }
}

/*:
 ### getName()
 > `getName` now returns a `String` instead of a `Character`
 
 **We must now enfore rules of a valid variable name**
 1. First character must be a letter
 2. The rest has be to `isAlphaNum`
 ```
 foobar1234 ✅
 1234foobar 🚫
 ```
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
    
    // Skip white-spaces at the end
    skipWhite()
    return tokens
}

/*:
 ### getNum()
 Same modifications to `getName` have been made here to parse multi-digit numbers!
 */
func getNum() -> String {
    if !isDigit(LOOK.cur) {
        expected("Name")
    }
    
    var value = ""
    // Loop and gather tokens
    while let cur = LOOK.cur, isDigit(cur) {
        value += String(cur)
        LOOK.getChar()
    }
    
    // Skip white-spaces at the end
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

var LOOK = initialize()
assignment()

if let cur = LOOK.cur, cur != CR {
    expected("Newline")
}

/*:
 ### So far...
 The parser is complete 🙌
 
 It's got every feature we could put in a one-line "compiler".
 
 In the next chapter, we will continue talking about expressions but will also talk about interpreters as opposed to compilers.
 
 ---
 ### End of Chapter 2 👋
 */
