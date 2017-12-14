/*:
 # LET'S BUILD A COMPILER 
 
 Welcome to LBaC (in Swift)!
 
 In the following series of Playgrounds, we will attempt to go through
 Jack W. Crenshaw's famous book in order to build a working compiler.
 
 The code provided here is the **minimal boiler plate code** we need to
 immediately get started on building a compiler.
 It consists of basic I/O, error, and other handling routines that don't need much attention for now.
 However, as we develop other routines, we will add them to the cradle until we get
 to a fully working compiler!!
 
 So, get excited and let's get started 🚀🚀🚀
 */

import Foundation

/*: 
 # Constant Declarations
 */
let TAB : Character = "\t"
let LF = "\n"
let whiteChars: [Character] = [" ", TAB]

/*:
 # The Lookahead Buffer
 */
/*:
 In the original LBaC, a single char `Look` is used as a global lookahead character
 that reads from the `stdin` in order to organize the scanning activites of a parser.
 
 But since we are in Playground and have no easy access to `stdin`, we will
 use a static string `input` that emulates user input to the parser.
 And as we process each character, `idx` and `cur` will be used to keep track 
 of where in `input` we are.
 */
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
    
    /// Advance to the next character in the buffer
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

/*: 
 # Utility Functions
 */

/// Report an Error
func error(msg: String) {
    print("Error: \(msg).")
}

/// Report error and halt
func abort(msg: String) {
    error(msg: msg)
    exit(EXIT_FAILURE)
}

/// Report what was expected
func expected(_ s: String) {
    abort(msg: "\(s) expected")
}

/// Output a String with tab
func emit(msg: String) {
    print("\(TAB) \(msg)", separator: "", terminator: "")
}

/// Output a String with tab and CRLF
func emitLine(msg: String) {
    print("\(TAB) \(msg)")
}

/// Recognize an alpha character
func isAlpha(_ c: Character?) -> Bool {
    if let c = c, "a"..."z" ~= c || "A"..."Z" ~= c {
        return true
    } else {
        return false
    }
}

/// Recognize a decimal digit
func isDigit(_ c: Character?) -> Bool {
    if let c = c, "0"..."9" ~= c {
        return true
    } else {
        return false
    }
}

/// Recognize an alphanumerical digit
func isAlnum(_ c: Character?) -> Bool {
    return isAlpha(c) || isDigit(c)
}

/*:
 # Compiler Logic Functions
 */

/// Match a specific input character
func match(_ c: Character) {
    if LOOK.cur == c {
        LOOK.getChar()
    } else {
        expected("\(c)")
    }
}

/// Get an identifier
func getName() -> Character {
    if !isAlpha(LOOK.cur) {
        expected("Name")
    }
    let upper = String(LOOK.cur!).uppercased().characters.first!
    LOOK.getChar()
    return upper
}

/// Get a number
func getNum() -> Character {
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    LOOK.getChar()
    return LOOK.cur!
}

/*:
 # Main Program
 
 `initialize()` serves to "prime the pump" by reading the
 first character from `input`. It uses the `Buffer` struct's `getChar()`.

 This is the one thing you should be worried about in this chapter!
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3")
    LOOK.getChar()
    return LOOK
}


var LOOK = initialize()
