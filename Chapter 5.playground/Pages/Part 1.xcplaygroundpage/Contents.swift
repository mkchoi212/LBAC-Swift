import Foundation

/*:
 # LBaC
 # Chapter V: Control Constructs
 ## Part 1: Introduction
 So far, we've been just dealing with mathematical expressions.
 And since real langauges have branches and loops and subroutines and more,
 you may be feeling that we are far away from being able to write a complete language.
 
 But believe it or not, it is far easier than writing parsers for expressions 😌

 ### The Plan
 We will start from the **bare cradle once again** and build up from there.
 We will also keep the concept of single-character tokens.
 ```
 i -> IF-STATEMENT
 w -> WHILE-STATEMENT
 ```
 
 We won't deal with assignment statements here because we proved we can implement them
 and we don't need them to hold us down. So instead, we will use an anonymous
 function `other` that will take place for any non-control statements and act
 as a place-holder for them.
 
 Also, we are back in compilation mode 😎
 
 ## The Implementation
 First thing is first; we need the ability to deal with more than one statmenet since a single-line for-loop / if-statement is going to be limited.

 ```
 <program> ::= <block> END
 <block> ::= [ <statement> ]*
 ```
 
 This BNF says that a program is defined as a block, followed by an `END`. A block, in turn, consists of
 an array of `statements`. What signals the end of a block? Any construct that isn't an `other` statement;
 for now, a `END` statement.
*/

/*:
 ### other()
 This will act as a place-holder, dummy function for any non-control statements
 */
func other() {
    emitLine(msg: "\(LOOK.getName())")
}

/*:
 ### block()
 A block of code in our compiler has to be followed by an `END` statement; denoted by `e`.
 
 In turn, a block may contain zero or more statements; `other` in our case.
 */
func block() {
    while let cur = LOOK.cur, !(["e"].contains(cur)) {
        other()
    }
}

/*:
 ### program()
 The main program runs `block` and checks to see if the last character in the program is indeed `e` to denote the `END` of the program.
 */
func program() {
    block()
    if let cur = LOOK.cur, cur != "e" {
        expected("End")
    }
    emitLine(msg: "END")    // This is to please the assembler
}

/*:
 ### So far...
 The output doesn't look like much! We've got a ways to go 😳
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "ae")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
program()
//: [Next](@next)
