import Foundation

/*:
 # LBaC
 # Part IV: Interpreters
 ## Still Interpreting...

 Continuing from what we did previously in 4-2.
 
 Finally, implementing `factor()` with support for parenthesis.
 We are almost there on making a useful interpreter!
 
> Check out the end for a little philosophy
 */

let TAB : Character = "\t"
let addOp: [Character] = ["+", "-"]
let mulOp: [Character] = ["*", "/"]

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
 ## Support factors and parenthesis
 We will hold off a bit longer on the variable names
 */
func factor() -> Int {
    let value: Int
    
    if let cur = LOOK.cur, cur == "(" {
        match("(")
        value = expression()
        match(")")
    } else {
        value = getNum()
    }
    
    return value
}

/*:
 > Calls to `getNum()` has been changed to `factor()`
 */
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

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "(60+3)/3")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
print("\(expression())")

/*:
 ## A Little Philosophy 📖
 
 > You can skip this but this little bit will help you understand how to
 simplify the mysterious process of making compilers.
 
 In the early days of compiler technology, people really stuggled trying to
 deal with things like opeartor precedence. People used 1, 2, 3 stacks with
 compiler precedence values that needed to be compared which then envolved more
 complicated steps. Other methods include using a parse tree, which is favored
 by many compiler textbooks.
 
 Anyways, we are doing similar things in our interpreter but we didn't use any stacks or trees.
 So, where are the stacks and the trees?
 
 **The answer is that the structures are implicit, not explicit.**
 
 Everytime Swift calls a `term()`, `expression()` or any subroutine, the return address is
 pushed onto the CPU stack. At the end, it's popped off and control is transferred.
 
 In other words, everything has been so simple because we have been using the resources
 provided by the language. Trees and stacks are all there but just hidden behind all the
 recursives calls made within Swift.
 
 ## TL;DR
 > **The lesson:** things can be easy when you do them right.
 >
 > **The warning:** take a look at what you're doing
 */
