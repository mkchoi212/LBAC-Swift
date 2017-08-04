import Foundation

/*:
 # LBaC
 # Part VI: Boolean Expressions
 ## Expansion
 
 In this section, we will build towards the following BNF rule
 ```
 <b-expression> ::= <b-term> [<orop> <b-term>]*
 ```
 */

let TAB : Character = "\t"

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

/*:
 ## OR and XOR
 */
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
    LOOK.getChar()
    return LOOK.cur!
}

/*:
 > Dummy relation
 All non-boolean factors are handled by this for now...
 */
func relation() {
    emitLine(msg: "<Relation>")
    LOOK.getChar()
}

/*:
 ## Boolean factor
 */
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

/*:
 ## Handle `NOT`
 */
func notFactor() {
    if let cur = LOOK.cur, cur == "!" {
        match("!")
        boolFactor()
        emitLine(msg: "EOR #-1,D0")
    } else {
        boolFactor()
    }
}

/*:
 ## Boolean term
 */
func boolTerm() {
    notFactor()
    while let cur = LOOK.cur, cur == "&" {
        emitLine(msg: "MOVE D0,-(SP)")
        match("&")
        notFactor()
        emitLine(msg: "AND (SP)+,D0")
    }
}

/*:
 ## Boolean expression
 */
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

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "B|T|!F&A")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
boolExpression()

/*:
 So far, we can parse `AND, ORs, NOTS`. Also, every non-boolean character is replaced by a
 `<Relation>` palceholder.
 
 We will implement the full version of it in the next section 🚀
 */
