import Foundation

/*:
 # LBaC
 # Part VI: Boolean Expressions
 ## Relation Expressions
 
 Here, we are going to fully implement `relation` and try to connect arithmetic and boolean
 expressions together.
 
 To do so, we will bring back the code we wrote previously to handle arithemtic parsing; remember
 `expression()`, `indent()` and `factor()`?
 
 Relation has the form
 ```
 <relation>     ::= | <expression> [<relop> <expression]`
 ```
 
 */

let TAB : Character = "\t"
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

/*:
 ## Relation's companion procedures
 */
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

/*:
 ## Recognize relational operators
 
 > **Not equals** is denoted by `#`
 */
func isRelOp(_ c: Character) -> Bool {
    return ["=", "#", "<", ">"].contains(String(c))
}

func isOrOp(_ c: Character) -> Bool {
    return ["|", "~"].contains(c)
}

func isBoolean(_ c: Character) -> Bool {
    return ["T","F"].contains(String(c).uppercased())
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
    let num = LOOK.cur!
    LOOK.getChar()
    return num
}

/*:
 ## Full blown relation
 
 Does the `expression()` look familiar??
 */
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

/*:
 ## expression parsing code from the past
 > The following code has been copied from 03-3.playground when we were doing single-character
 parsing
 */
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


func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "x>2+3&x<2+5")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
boolExpression()

/*:
 Now we can parse both arithmetic AND boolean algebra! 🚀🚀🚀
 */
