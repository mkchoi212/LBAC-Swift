import Foundation
/*:
 # LBaC
 # Part X: Introducing "TINY"
 ## Part 3: Declarations
 
 For TINY, we will have 2 types of declarations
 1. Variables
 2. Functions
 
 For now, we will deal only with variable declarations; denoted by `VAR` or `v`
 
 > At the top level, only global declarations are allowed; just like C.
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

func postLabel(_ label: String) {
    print("\(label):", terminator:"")
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

func getNum() -> Character {
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    LOOK.getChar()
    return LOOK.cur!
}

func header() {
    emitLine(msg: "WARMST\tEQU $A01E")
}

func prolog() {
    postLabel("MAIN")
}

func epilog() {
    emitLine(msg: "DC WARMST")
    emitLine(msg: "END MAIN")
}

func main() {
    match("b")
    prolog()
    match("e")
    epilog()
}

/*:
 ### decl()
 This function parses data declarations but is a stub for now.
 
 > For now, it doesn't generate any code or process a list.
 */
func decl() {
    match("v")
    LOOK.getChar()  // STUB
}

/*:
 ### topDecl()
 Since TINY only has one type - 16 bit integer - we don't need to declare the type.
 
 Later for full KISS, we can easily add the type description.
 */
func topDecl() {
    while let cur = LOOK.cur, cur != "b" {
      switch cur {
      case "v":
        decl()
      default:
        abort(msg: "Unrecognized keyword \(cur)")
      }
    }
}

func prog() {
    match("p")
    header()
    topDecl()
    main()
    match(".")
}

/*:
 ## So far...
 We can now have many declarations that start with a `v` for `VAR`. But they *must be in seperate lines for now*!.
 
 > Try a couple of cases and see what happens!
 ```
 PROGRAM
 VAR a
 VAR c
 BEGIN
 END
 ```
 is denoted by `pvavcbe.`
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "pvavcbe.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
    abort(msg: "Unexpected data after `.`")
}
