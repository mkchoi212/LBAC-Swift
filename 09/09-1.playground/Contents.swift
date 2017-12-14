import Foundation
/*:
 # LBaC
 # Part IX: A Top View
 ## Up VS. Down
 The program we have developed so far has a decidedly *bottom-up flavor*. For example, in the case of expression parsing, we began with the lowest level constructs and worked our way up to more complex expressions.
 
 So now, we will build a translator for a subset of the KISS language, which we will call TINY in a **top-down fashion**.
 
 ## Top-Level
 Biggest mistake people make in a top-down design is *not starting at the true top.* For our program, we will do it right by looking at the three possible top-level recognizers.
 
 First recognizer is `prog()`, which is the progam itself
 */

let TAB : Character = "\t"
let LF = "\n"
let whiteChars: [Character] = [" ", TAB]

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

/// Write the prolog
func prolog() {
    emitLine(msg: "WARMST EQU $A01E")
}

/// Write the epilog
func epilog(_ name: Character) {
    emitLine(msg: "DC WARMST")
    emitLine(msg: "END \(name)")
}

/*:
 ## prog
 `prolog` and `epilog` perform whatever is required to let the program interface with the OS; they will be VERY OS-dependent.
 
 Until now, we have been emitting code for a 68000 which runs on SK*DOS and its too late to change... so we will stick to it
 */
/// Parse and translate a program where `p` stands for `PROGRAM`
func prog() {
    match("p")
    let name = getName()
    prolog()
    match(".")
    epilog(name)
}

/*:
 ## Few things to note
 Only legal input so far is `px.` where x is a single letter indicating the program's name
 
 Not too impressive, I know. But note that the output is a **COMPLETE EXECUTABLE PROGRAM**.
 
 This is **⚠️VERY IMPORTANT⚠️** because the nice feature of the top-down approach is that at any stage, you can compile a subset of the language and get a program that will run! From here, we only need to add features.
 */
 
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "px.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
