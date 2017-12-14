import Foundation
/*:
 # LBaC
 # Part IX: A Top View
 ## Part 3: Declarations
 Implementing `declarations()`
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

/*:
 > Dummy functions for declaration types
 */
func labels() {
    match("l")
}

func types() {
    match("t")
}

func constants() {
    match("c")
}

func variables() {
    match("v")
}

func doProcedure() {
    match("p")
}

func doFunction() {
    match("f")
}

/*:
 # declarations
  Declarations need to support a few things. As usual, we will represent each declaration types with a single character.
 
 For the time being, we will use dummy functions for all the declaration types.
 > This time, the dummy functions will have to at least eat the character that invoked it. Or else, we will be stuck in an infinite loop.
 */
func declarations() {
    let decTypes : Set<Character> = Set(["l", "c", "t", "v", "p", "f"])
    while let cur = LOOK.cur, decTypes.contains(cur) {
        switch cur {
        case "l":
            labels()
        case "c":
            constants()
        case "t":
            types()
        case "v":
            variables()
        case "p":
            doProcedure()
        case "f":
            doFunction()
        default:
            break
        }
    }
}

func statements() {
    
}

/*:
 ## The doBlock
 doBlock just folows what a block should look like. Declarations followed by statements.
 
 The insertion of label via `postLabel` has to do with the operation of SK*DOS. Unlike most OS's, SK*DOS allows the entry point to the main program to be anywhere in the program. All you have to do is give that point a name.
 
 `postLabel` does this by putting that name just before the first `statement`.
 
 > `declarations` and `statements` are dummy functions for now. We will make them in the next part
 */
func doBlock(name: Character) {
    declarations()
    postLabel(String(name))
    statements()
}

func prolog() {
    emitLine(msg: "WARMST EQU $A01E")
}

func epilog(_ name: Character) {
    emitLine(msg: "DC WARMST")
    emitLine(msg: "END \(name)")
}

func prog() {
    match("p")
    let name = getName()
    prolog()
    doBlock(name: name)
    match(".")
    epilog(name)
}

/*:
 You can try out the compiler with various declaration types, as long as the last character in the program is `.` to indicate end of the program.
 
 Of course, none of the declarations actually don't declare anything; for now.
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "pxvc.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
