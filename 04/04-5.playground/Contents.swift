import Foundation

/*:
 # LBaC
 # Part IV: Interpreters
 ## Assignment
 
 So far, we implemented `table`, a variable responsible for storing variable's
 data. In the last Playground, we were only able to retrieve from `table` but not
 store data INTO it.
 
 Also, we can only change a single line right now. That's not too useful, is it?
 
 Let's change all that 😎
*/

let TAB : Character = "\t"
let addOp: [Character] = ["+", "-"]
let mulOp: [Character] = ["*", "/"]

var table: [Character:Int] = [:]

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

func isAlnum(_ c: Character?) -> Bool {
    return isAlpha(c) || isDigit(c)
}

func match(_ c: Character) {
    if LOOK.cur == c {
        LOOK.getChar()
    } else {
        expected("\(c)")
    }
}

/*:
 ## Handle multiple lines
 Recognize a newline and skip over it to proceed to the next line
 */
func newline() {
    if let cur = LOOK.cur, cur == "\n" {
        LOOK.getChar()
        
    }
}

func getName() -> Character {
    if !isAlpha(LOOK.cur) {
        expected("Name")
    }
    let lower = String(LOOK.cur!).lowercased().first!
    LOOK.getChar()
    return lower
}

func getNum() -> Int {
    var value = 0
    
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    
    while isDigit(LOOK.cur) {
        value = (10 * value) + Int(String(LOOK.cur!))!
        LOOK.getChar()
    }
    
    return value
}

func assignment() {
    let name = getName()
    match("=")
    table[name] = expression()
}

func factor() -> Int {
    let value: Int
    
    if let cur = LOOK.cur, cur == "(" {
        match("(")
        value = expression()
        match(")")
    } else if isAlpha(LOOK.cur) {
        value = table[LOOK.cur!]!
    } else {
        value = getNum()
    }
    
    return value
}

func term() -> Int {
    var value = factor()

    while let cur = LOOK.cur, mulOp.contains(cur) {
        switch cur {
        case "*":
            match("*")
            value *= factor()
        case "/":
            match("/")
            value /= factor()
        default:
            expected("* or /")
        }
    }
    
    return value
}

func expression() -> Int {
    var value: Int
    
    if let cur = LOOK.cur, addOp.contains(cur) {
        value = 0
    } else {
        value = term()
    }
    
    while let cur = LOOK.cur, addOp.contains(cur) {
        switch cur {
        case "+":
            match("+")
            value += term()
        case "-":
            match("-")
            value -= term()
        default:
            expected("+ or -")
        }
    }
    
    return value
}

func initTable() {
    for val in UnicodeScalar("a").value...UnicodeScalar("z").value {
        table[String(UnicodeScalar(val)!).first!] = 0
    }
}

func initialize() -> Buffer {
    initTable()
    // Notice the period at the end
    var LOOK = Buffer(idx: 0, cur: nil, input: "a=(60/2)+3\nb=9.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()

/*:
 ## The Loop
 To process multiple lines, we are going to place a loop.
 But we need some kind of *termination character* that let's us know
 when we can stop the loop.
 
 Here, we are going to use Pascal's ending period `(.)`
 */
while let cur = LOOK.cur, cur != "." {
    assignment()
    newline()
}
print("a = \(table["a"]!)")
print("b = \(table["b"]!)")

