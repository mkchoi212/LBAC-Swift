import Foundation

/*:
 # LBaC
 # Part IV: Interpreters
 ## I/O
 
 In the last section, we were able to build a functioning interpreter!
 However, what's good if we don't havea way to read data in order write
 it out?
 
 We need some **I/O.**
 
 Let's finish chapter 4 by adding some I/O routines.
 - `?`  indicates a `read`
 - `!`  indicates a `write`
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

/*:
 ## Reading
 In a real interpreter, we would **read** an input
 from the user but since we are in a Playground, we will
 just read from the static string like always.
 
 > ex: `!a` prints the contents of variable `a`
 */
func input() {
    match("?")
    let variable = getName()
    if let cur = LOOK.cur {
        table[variable] = Int(String(cur))
        LOOK.getChar()
    }
}

/*:
 ## Printing
 To make things look pretty, we are going to print the variables
 in the format `VAR = VAL`
 
 > ex: `?z3` reads `3` into `z`
 */
func output() {
    match("!")
    print("\(LOOK.cur!) = \(table[getName()]!)")
}

func initTable() {
    for val in UnicodeScalar("a").value...UnicodeScalar("z").value {
        table[String(UnicodeScalar(val)!).first!] = 0
    }
}

func initialize() -> Buffer {
    initTable()
    var LOOK = Buffer(idx: 0, cur: nil, input: "a=(60/2)+3\n" +
                                               "b=9\n"        +
                                               "!a!b\n"       +
                                               "?z3!z.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()

while let cur = LOOK.cur, cur != "." {
    // Notice the new cases
    switch cur {
    case "?":
        input()
    case "!":
        output()
    default:
        assignment()
    }
    newline()
}

/*:
 # Overview
 
 Congratulations, we built a somewhat working interpreter 🎉🎉🎉
 
 It's **features** are
 - Three kinds of program statements
 - Support for 26 variables
 - I/O  statements
 
 but **lacks**
 - Control statements
     - *covered next chapter*
 - Subroutines
     - *covered next..next chapter*
 - Program editing function
     - *❗not covered; here to learn things not build products*
 */


