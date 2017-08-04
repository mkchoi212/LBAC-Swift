import Foundation

/*:
 # LBaC
 # Part VI: Boolean Expressions
 ## Merging with control constructs
 
 We are going to now merge the code we previously wrote to deal with control constructs with the boolean
 expression parsing code we just wrote.
 
 What I did here is copy the old control construct parsing code from `05-9.playground` and replace
 the dummy function `condition` with `boolExpression`.
 
 I know it's a lot of code but we've covered all of it so take your time as your go through it.
 */

let TAB : Character = "\t"
var LCNT: Int = 0
let addOp: [Character] = ["+", "-"]

struct Buffer {
    var idx : Int
    var cur : Character?
    let input: String
}

extension Buffer {
    init() {
        idx = 0
        input = ""
        getChar()
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

func isBoolean(_ c: Character) -> Bool {
    return ["T","F"].contains(String(c).uppercased())
}

func isRelOp(_ c: Character) -> Bool {
    return ["=", "#", "<", ">"].contains(String(c))
}

func isOrOp(_ c: Character) -> Bool {
    return ["|", "~"].contains(c)
}

func isAlpha(_ c: Character) -> Bool {
    if "a"..."z" ~= c || "A"..."Z" ~= c {
        return true
    } else {
        return false
    }
}

func isDigit(_ c: Character) -> Bool {
    if "0"..."9" ~= c {
        return true
    } else {
        return false
    }
}

func isAlnum(_ c: Character) -> Bool {
    return isAlpha(c) || isDigit(c)
}

func match(_ c: Character) {
    if LOOK.cur == c {
        LOOK.getChar()
    } else {
        expected("\(c)")
    }
}

func getBoolean() -> Bool {
    if let cur = LOOK.cur, !isBoolean(cur) {
        expected("Boolean Literal")
    }
    
    let boolVal = String(LOOK.cur!).uppercased() == "T"
    LOOK.getChar()
    return boolVal
}

func getName() -> Character {
    if let cur = LOOK.cur, !isAlpha(cur) {
        expected("Name")
    }
    let upper = String(LOOK.cur!).uppercased().characters.first!
    LOOK.getChar()
    return upper
}

func getNum() -> Character {
    if let cur = LOOK.cur, !isDigit(cur) {
        expected("Integer")
    }
    LOOK.getChar()
    return LOOK.cur!
}

func newLabel() -> String {
    let label = "L\(String(LCNT))"
    LCNT += 1
    return label
}

func postLabel(_ label: String) {
    print("\(label):", terminator:"")
}

func other() {
    emitLine(msg: "\(getName())")
}

func boolOr() {
    match("|")
    boolTerm()
    emitLine(msg: "OR (SP)+,D0")
}

func boolXor() {
    match("~")
    boolTerm()
    emitLine(msg: "EOR (SP)+,D0")
}

func equals() {
    match("=")
    expression()
    emitLine(msg: "CMP (SP)+,D0")
    emitLine(msg: "SEQ D0")
}

func notEquals() {
    match("#")
    expression()
    emitLine(msg: "CMP (SP)+,D0")
    emitLine(msg: "SNE D0")
}

func less() {
    match("<")
    expression()
    emitLine(msg: "CMP (SP)+,D0")
    emitLine(msg: "SGE D0")
}

func greater() {
    match(">")
    expression()
    emitLine(msg: "CMP (SP)+,D0")
    emitLine(msg: "SLE D0")
}

func relation() {
    expression()
    if let cur = LOOK.cur, isRelOp(cur) {
        emitLine(msg: "MOVE D0,-(SP)")
        switch cur {
        case "=":
            equals()
        case "#":
            notEquals()
        case "<":
            less()
        case ">":
            greater()
        default:
            expected("Relational operator")
        }
        emitLine(msg: "TST D0")
    }
}

func boolFactor() {
    if let cur = LOOK.cur, isBoolean(cur) {
        if getBoolean() {
            emitLine(msg: "MOVE #-1,D0")
        } else {
            emitLine(msg: "CLR D0")
        }
    } else {
        relation()
    }
}

func notFactor() {
    if let cur = LOOK.cur, cur == "!" {
        match("!")
        boolFactor()
        emitLine(msg: "EOR #-1,D0")
    } else {
        boolFactor()
    }
}

func boolTerm() {
    notFactor()
    while let cur = LOOK.cur, cur == "&" {
        emitLine(msg: "MOVE D0,-(SP)")
        match("&")
        notFactor()
        emitLine(msg: "AND (SP)+,D0")
    }
}

func boolExpression() {
    boolTerm()
    while let cur = LOOK.cur, isOrOp(cur) {
        emitLine(msg: "MOVE D0,-(SP)")
        switch cur {
        case "|":
            boolOr()
        case "~":
            boolXor()
        default:
            expected("| or ~")
        }
    }
}

func indent() {
    let name = getName()
    if let cur = LOOK.cur, cur == "(" {
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
        indent()
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
    
    while let cur = LOOK.cur, ["*","/"].contains(cur) {
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


/*:
 ## Old control construct code
 */

/*:
 > `d` is for `doDo()`
 */
func block() {
    while let cur = LOOK.cur, !(["e", "l", "u"].contains(cur)) {
        switch cur {
        case "i":
            doIf()
        case "w":
            doWhile()
        case "p":
            doLoop()
        case "r":
            doRepeat()
        case "f":
            doFor()
        case "d":
            doDo()
        default:
            other()
        }
    }
}

/*:
 > Every call to this dummy function `condition` has been replaced with `boolExpression
 func condition() {
 emitLine(msg: "<condition>")
 }
 */
func doDo() {
    match("d")
    let L1 = newLabel()
    expression()
    emitLine(msg: "SUBQ #1,D0")
    postLabel(L1)
    emitLine(msg: "MOVE D0,-(SP)")
    block()
    emitLine(msg: "MOVE (SP)+,D0")
    emitLine(msg: "DBRA D0,\(L1)")
}

func doFor() {
    match("f")
    let L1 = newLabel()
    let L2 = newLabel()
    
    let name = getName()
    match("=")
    expression()
    emitLine(msg: "SUBQ #1,D0")
    emitLine(msg: "LEA \(name)(PC),A0")
    emitLine(msg: "MOVE D0,(A0")
    expression()
    emitLine(msg: "MOVE D0,-(SP)")
    postLabel(L1)
    emitLine(msg: "LEA \(name)(PC),A0")
    emitLine(msg: "MOVE (A0),D0")
    emitLine(msg: "ADDQ #1,D0")
    emitLine(msg: "MOVE D0,(A0)")
    emitLine(msg: "CMP (SP),D0")
    emitLine(msg: "BGT \(L2)")
    block()
    match("e")
    emitLine(msg: "BRA \(L1)")
    postLabel(L2)
    emitLine(msg: "ADDQ #2,SP")
}

func doRepeat() {
    match("r")
    let label = newLabel()
    postLabel(label)
    block()
    match("u")
    boolExpression()
    emitLine(msg: "BEQ \(label)")
}

func doLoop() {
    match("p")
    let label = newLabel()
    postLabel(label)
    block()
    match("e")
    emitLine(msg: "BRA \(label)")
}

func doWhile() {
    var L1, L2: String
    match("w")
    L1 = newLabel()
    L2 = newLabel()
    postLabel(L1)
    boolExpression()
    emitLine(msg: "BEQ \(L2)")
    block()
    match("e")
    emitLine(msg: "BRA \(L1)")
    postLabel(L2)
}

func doIf() {
    var L1, L2: String
    
    match("i")
    boolExpression()
    L1 = newLabel()
    L2 = L1
    emitLine(msg: "BEQ \(L1)")
    block()
    
    if let cur = LOOK.cur, cur == "l" {
        match("l")
        L2 = newLabel()
        emitLine(msg: "BRA \(L2)")
        postLabel(L1)
        block()
    }
    
    match("e")
    postLabel(L2)
}

func program() {
    block()
    if let cur = LOOK.cur, cur != "e" {
        expected("End")
    }
    emitLine(msg: "END")
}

/*:
 `ia=bxlye` means `IF a=b X ELSE Y ENDIF`
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "ia=bxlye")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
program()

