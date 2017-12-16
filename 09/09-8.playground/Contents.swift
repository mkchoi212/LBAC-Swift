import Foundation
/*:
 # LBaC
 # Part IX: A Top View
 ## Part 8: C (final)

 Assume the next thing we have to tackle is the **name of whatever we are dealing with** in the parser.
 
 If the name is followed by a `(`, we have a **function declaration**.
 
 ```
 int foobar(   <- this is a function!
 ```
 
 If not, we have at least one data item and possibly a list, where each element could have an initializer.
 
 ```
 int foobar,  <- NOT a function
 int foobar, barfoo, ...
 ```
 */

var CLASS : Character!
var SIGN : Character!
var TYPE: Character!

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

func getClass() {
  if let cur = LOOK.cur, ["a", "x", "s"].contains(cur) {
    CLASS = cur
    LOOK.getChar()
  } else {
    CLASS = "a"
  }
}

func getType() {
  TYPE = " "
  if let cur = LOOK.cur, cur == "u" {
    SIGN = "u"
    TYPE = "i"
    LOOK.getChar()
  } else {
    SIGN = "s"
  }
  
  if let cur = LOOK.cur, ["i", "l", "c"].contains(cur) {
    TYPE = cur
    LOOK.getChar()
  }
}

/*:
 ### doFunc
 
 Receive data from `topDecl` and parse the function
 */
func doFunc(_ n: Character) {
  match("(")
  match(")")
  match("{")
  match("}")
  
  if TYPE == " " {
    TYPE = "i"
  }
  
  emitLine(msg: "\(CLASS!) \(SIGN!) \(TYPE!) function \(n)")
}

/*:
 ### doFunc
 
 Receive data from `topDecl` and parse the data
 */
func doData(_ n: Character) {
  var name = n
  
  if TYPE == " " {
    expected("Type Declaration")
  }
  
  emitLine(msg: "\(CLASS!) \(SIGN!) \(TYPE!) data \(name)")
  
  while let cur = LOOK.cur, cur == "," {
    match(",")
    name = getName()
    emitLine(msg: "\(CLASS!) \(SIGN!) \(TYPE!) data \(name)")
  }
  match(";")
}

/*:
 > We read the name, we must pass it to the right function
 */
func topDecl() {
  let name = getName()
  if let cur = LOOK.cur, cur == "(" {
    doFunc(name)
  } else {
    doData(name)
  }
}

func prog() {
    while LOOK.cur != nil {
      getClass()
      getType()
      topDecl()
    }
}

/*:
 we are still long ways from a C compiler. But we are at a good starting to process the right kind of inputs and recognizing good from bad inputs.
 
 > We can't process initializers and argument lists for functions
 
 ## Notes on the future
 I don't know about you but I am starting to get 😵.
 
 We could continue on with this to make a working compiler but remember that our purpose here is to not build a compiler but to **LEARN** about compilers in general.
 
 > ⚠️⚠️⚠️ From now on, we will start to develop a complete compiler for TINY, a subset of KISS language 💋💋💋.
 
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "ic(){}uca,b,c;")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
