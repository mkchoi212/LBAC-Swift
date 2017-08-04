import Foundation

/*:
 # LBaC
 # Part IV: Interpreters
 ## Variables
 
 In the compiler, all we had to do was to just issue the names
 to the asembler and let it take care of allocating storage for them.
 Here, **we need to be able to fetch the values when we need them. So,
 what we need is a storage mechanism for the variables.** We will use
 Swift's `Dictionary` type for that.
 
 And just like Tiny BASIC, we will have 26 possible variables; one for each
 letter in the alphabet (lower-case)
*/

let TAB : Character = "\t"
let addOp: [Character] = ["+", "-"]
let mulOp: [Character] = ["*", "/"]

/*:
 > `table` will be the variable responsible for holding all the variables
 */
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

func getName() -> Character {
    if !isAlpha(LOOK.cur) {
        expected("Name")
    }
    let upper = String(LOOK.cur!).uppercased().characters.first!
    LOOK.getChar()
    return upper
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

/*:
 ## Fetching variable's data
 
 So far, we don't have a way to set variables so
 `factor` will always return a `0` for them;
 a slight inconvenience but everything get parsed correctly.
 */
 
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
 > Initialize `table` dictionary with the alphabet as the keys
 and zero as the default values
 */
func initTable() {
    for val in UnicodeScalar("a").value...UnicodeScalar("z").value {
        table[String(UnicodeScalar(val)!).first!] = 0
    }
}

func initialize() -> Buffer {
    initTable()
    var LOOK = Buffer(idx: 0, cur: nil, input: "a=(60/2)+3")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
print("\(expression())")
