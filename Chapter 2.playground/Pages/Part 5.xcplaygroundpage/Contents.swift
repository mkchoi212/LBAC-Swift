//: [Previous](@previous)
/*:
 # LBaC
 # Chapter II: Expression Parsing
 ## Part 5: Unary Minus
 
 So you may have noticed putting `-1` as the `input` crashed the compiler. How do we fix this?

 There are many ways to fix this but the easiest is to put an **imaginary zero** in front of expressions.
 ```
 +3 -> 0+3
 -2 -> 0-2
 ```
 It's a bit hacky but it's kind of elegant at the same time 💃🏻
 */

let addOp : [Character] = ["+", "-"]
let mulOp : [Character] = ["*", "/"]

func factor() {
    guard let cur = LOOK.cur else { return }
    
    if cur == "(" {
        LOOK.match("(")
        expression()
        LOOK.match(")")
    } else {
        emitLine(msg: "MOVE #\(LOOK.getNum()),D0")
    }
}

func multiply() {
    LOOK.match("*")
    factor()
    emitLine(msg: "MULS (SP)+,D1")
}

func divide() {
    LOOK.match("/")
    factor()
    emitLine(msg: "MULS (SP)+,DO")
    emitLine(msg: "DIVS D1, D0")
}

func add() {
    LOOK.match("+")
    term()
    emitLine(msg: "ADD (SP)+,D0")
}

func subtract() {
    LOOK.match("-")
    term()
    emitLine(msg: "SUB (SP)+,D0")
    emitLine(msg: "NEG D0")
}

func term() {
    factor()
    
    while let cur = LOOK.cur, mulOp.contains(cur) {
        emitLine(msg: "MOVE D0,-(SP)")
        switch String(cur) {
        case "*":
            multiply()
        case "/":
            divide()
        default:
            expected("* or /")
        }
    }
}

/*:
 ### expression()
 This now checks if the current character - `cur` - is an `addOp` - `+-`.
 
 If it is, it places a zero in the D0 register by simply clearing it before going on with execution.
 */
func expression() {
    guard let cur = LOOK.cur else { return }
    
    // Place imaginary 0 by clearing D0 register
    if addOp.contains(cur) {
        emitLine(msg: "CLR D0")
    } else {
        term()
    }
    
    while let cur = LOOK.cur, addOp.contains(cur) {
        emitLine(msg: "MOVE D0,-(SP)")
        switch String(cur) {
        case "+":
            add()
        case "-":
            subtract()
        default:
            expected("+ or -")
        }
    }
}

func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "-1")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
expression()

/*:
 # Notes on optimization
 > This section is not required and you may skip it. But note that it does contain some interesting facts!
 
 Ok, so optimizing code is not that difficult. There are three approaches to it.
 ## 1. **Fix the code after it's generated**
 
 This is the concept of "peephole" optimization. Idea is that since we know
 what kind of code the compiler will generate and which ones are bad,
 we can look at the produced code and replace the bad ones with good ones.

 In other words, this is basically bunch of macro expansions and
 straight up pattern-matching; with LOTS of patterns. And it's called "peephole" since
 it looks for small patterns of instructions at a time.
 
 This method does have drastic effect to the quality of generated code with little effort.
 But *speed, size, and complexity of the compiler grows*; imagine all the `IF-STATEMENTS` you'd have to write 😑
 
 ## 2. **Generate good code in the first place**
 
 This looks at special cases **BEFORE** we emit them. For example, before we
 add a zero to a number, we could emit a `CLR` instead of a `load` and or do nothing.
 
 ## 3. **Don't use CPU stacks**
 680000 has 8 data registers and we could use them as a **privately managed stack** for expressions up to
 8 data points. If we need more than 8 levels of stack, we can let the stack *spill over* to the
 CPU stack to gain more space.
 
 Don't think too much about this right now. Because as a wise man once said...
 > **Premature optimization is the root of all evil.**
 
 ---
 ### End of Chapter 2
 */
