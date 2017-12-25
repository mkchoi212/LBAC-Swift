import Foundation

/*:
 # LBaC
 # Chapter IV: Interpreters
 ## Part 1: Introduction
 
 In the last chapter, we finished building a **compiler** that can parse and compile math expressions. This time, we will focus on building an **INTERPRETER** and go through the **same process one more time.**.
 
 You may ask, *"Hey! I thought the book was called Let's Build a *compiler* and not *interpreter*?!".
 
 Yes, but I want you to see how the nature of the parser changes as we change our goals. I also want to unify the concepts of two types of translators so you can see the differences and the similarities.

 ## Compiler VS. Interpreter
 ```
 1 + 2 + 3
 ```
 When a compiler receives the expression above, it spits out complex machine code that will be later exectued by the CPU.
 
 However, when an interpreter receives the above expression, it simply prints out `6`.
 
 ## What changes do we have to make?
 The structure of the parser won't change. It's only the actions that change.
 So, if you can write a compiler for a language, you can easily write an interpreter for it!
 
 The BIG difference is that because our end goal is different, *procedures
 that do the recognizing is different.* When recognizing procedures, interpreters now return **FUNCTIONS** that return numeric values.
 
 ## Lazy Translation
 It's an idea that you don't just emit code at every action. Instead, you don't emit anything **unless you really have to.**
 
 ```
 x = x + 3 - 2 - (5 - 4)     // This is reduced during compile time to...
 x = x + 0                   // ... which is reduced once more
 x = x                       // to this which doesn't require any actions!
 ```
 > Lazy evaluation complicates the parser significantly so we won't talk about it too much here
 
 ## So...
 To start, let's start with a **BARE CRADLE** and build it up from ground up.
 This time we are going to go through things faster so hold on tight 🏃‍♂️🏃‍♂️🏃‍♂️
 */

/*:
 ### getNum()
 Since we have to actually perform the calculations, `getnNum` now returns an `Int`
 */
func getNum() -> Int {
    if !isDigit(LOOK.cur) {
        expected("Integer")
    }
    
    let num = Int(String(LOOK.cur!))!
    LOOK.getChar()
    return num
}

/*:
 ### expression()
 Right away, you can see there is no `add` and `subtract` functions.
 
 All we now have is a local variable `value` that keeps track of things.
 
 > This probably won't work for lazy evaluation 😆
 */
func expression() -> Int {
    var value: Int
    
    if let cur = LOOK.cur, addOp.contains(cur) {
        value = 0
    } else {
        value = getNum()
    }
    
    while let cur = LOOK.cur, addOp.contains(cur) {
        switch cur {
        case "+":
            LOOK.match("+")
            value += getNum()
        case "-":
            LOOK.match("-")
            value -= getNum()
        default:
            expected("+ or -")
        }
    }
    
    return value
}

/*:
 ### So far...
 We can evaluate simple mathematical expressions that add or subtract!
 
 That wasn't too bad, was it? Let's keep going then 🏃🏃🏃🏃🏃🏃🏃
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "3+2")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
print(">> \(expression())")
//: [Next](@next)

