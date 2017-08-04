import Foundation

/*:
 # LBaC
 # Part V: Control Constructs
 ## Groundwork
 
 Previous part's output was not much but we are getting there.
 
 But before we begin defining control structures, we need to lay some groundwork.
 Note that our syntax will look a bit like [Ada](https://en.wikibooks.org/wiki/Ada_Programming/Basic).
 
 `IF` statements look like the following in Ada.
 ```
 IF <condition> <block> ENDIF
 ```
 
 At this point, we need some kind of concept that helps us keep track of various branches.
 We are going to use unique `label`s to help us organize them.
*/

let TAB : Character = "\t"

/*:
 > New global var for counting number of `label`s
 */
var LCNT: Int = 0

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

func getNum() -> Character {
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    LOOK.getChar()
    return LOOK.cur!
}

/*:
 ## Creating labels
 Labels allow us to keep track of various branches.
 
 This generates unique labels with the form `LXX`
 where `XX` is the label number starting from 0
 */
func newLabel() -> String {
    let label = "L\(String(LCNT))"
    LCNT += 1
    return label
}

/*:
 Just writes the labels
 */
func postLabel(_ label: String) {
    emitLine(msg: "\(label):")
}

func other() {
    emitLine(msg: "\(getName())")
}

func block() {
    while let cur = LOOK.cur, !(["e"].contains(cur)) {
        other()
    }
}

func program() {
    block()
    if let cur = LOOK.cur, cur != "e" {
        expected("End")
    }
    emitLine(msg: "END")
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "ae")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
program()
