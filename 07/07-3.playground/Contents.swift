import Foundation
/*:
 # LBaC
 # Part VII: Lexical Scanning
 ## New Lines
 
 The simplest way to handle multiple lines in our scanner is to **treat newline as white space**.
 
 This is how C does it by the way with their `isWhite`.
 */

let LF: Character  = "\n"
let TAB: Character = "\t"
let whiteChars: [Character] = [" ", TAB, LF]

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

func isWhite(_ c: Character) -> Bool {
    return whiteChars.contains(c)
}

func skipWhite() {
    while let c = LOOK.cur, isWhite(c) {
        LOOK.getChar()
    }
}

/*:
 > Used previously in chapter 6 when we had to eat up newlines
 */
func fin() {
    if let cur = LOOK.cur, cur == "\n" {
        LOOK.getChar()
    }
}

func match(_ c: Character) {
    if LOOK.cur == c {
        LOOK.getChar()
    } else {
        expected("\(c)")
    }
}

func getName() -> String {
    var token = ""
    if let c = LOOK.cur, !isAlpha(c) {
        expected("Name")
    }
    
    while let c = LOOK.cur, isAlnum(c) {
        token += String(c).uppercased()
        LOOK.getChar()
    }
    skipWhite()
    return token
}

func getNum() -> String {
    var token = ""
    if let c = LOOK.cur, !isDigit(c) {
        expected("Integer")
    }
    
    while let c = LOOK.cur, isDigit(c) {
        token += String(c)
        LOOK.getChar()
    }
    skipWhite()
    return token
}

/*:
 Because we want our language to be free field, newlines should be transparent.
 `scan` now eats up all line feeds with `fin`.
 
 > Play around with different arrangments to see how you like them. If you want a line-oriented
 language's behavior - like FORTRAN/BASIC/PYTHON - you'll need `scan` to return line feeds as tokens
 */
func scan() -> String {
    var token = ""
    guard let c = LOOK.cur else { fatalError("EOF") }
    
    while let c = LOOK.cur, c == LF {
        fin()
    }
    
    if isAlpha(c) {
        token = getName()
    } else if isDigit(c){
        token = getNum()
    } else {
        token = String(c)
        LOOK.getChar()
    }
    skipWhite()
    return token
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "\n\n\n now is the time\nfor all good men.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()

var token: String

/*:
 > Since we will never face a CR, the terminating character is now a `.` - a dot
 */
repeat {
    token = scan()
    print(token)
} while(token != ".")
