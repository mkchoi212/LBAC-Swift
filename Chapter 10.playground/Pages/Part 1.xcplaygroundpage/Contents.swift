import Foundation
/*:
 # LBaC
 # Chapter X: Introducing "TINY"
 ## Part 1: Introduction
 
 If you don't remember, we were last trying to build Pascal/C compilers in previous chapters in a top-down fashion. However, we stopped during the process because I deemed it would be more fun to write a compiler for a language called `KISS` - specifically a subset called **TINY**.
 
 Here, we will take a slightly untraditional route. We will be *defining the language as we go*. Actually, we will be doing a top-down development for both the language and its compiler.
 
 > Along the way, we will make important decisions. If you don't agree, you can do whatever you'd like to do! It's your compiler after all!
 
 Now... we will start once again from a blank sheet of paper. Get excited 🤩🤩🤩
 
 ## About TINY
 TINY is a subset of KISS and because of this, there will be certain limitations to TINY.
 
 - Only one data type (16 bit integer)
 - No procedure calls
 - Single-character variable names
 
 But in a general sense, TINY will be similar to Pascal in some sense.
 */

/*:
 ### header()
 Emits startup code required by the assembler
 */
func header() {
    emitLine(msg: "WARMST\tEQU $A01E")
}

/*:
 ### prolog & epilog
 Emits code for identifying the main program and returning it to the OS
 */
func prolog() {
  postLabel("MAIN")
}

func epilog() {
    emitLine(msg: "DC WARMST")
    emitLine(msg: "END MAIN")
}

/*:
 ### Main Blocks
 We will keep the `PROGRAM`, `.` syntax to denote beginning and end of main blocks.
 */
func prog() {
    LOOK.match("p")
    header()
    prolog()
    LOOK.match(".")
    epilog()
}

/*:
 ### So far...
 TINY will only accept on input
 ```
 PROGRAM .
 ```
 or `p.` in shorthand.
 
 > Short and useless as it is, the code generated by our compiler will run and do what you'd expect it to do; nothing.
 
 > Compiling, linking and executing null programs can actually reveal many interesting things about the compiler. *VAX C generated 50K of code for a null program 😳*
 
 Since we don't have any run-time libraries, our's is tiny.... **2 bytes** 🎉🎉🎉
 */
func initialize() -> Buffer {
    var LOOK = Buffer(idx: 0, cur: nil, input: "p.")
    LOOK.getChar()
    return LOOK
}

var LOOK = initialize()
prog()
if LOOK.cur != nil {
    abort(msg: "Unexpected data after `.`")
}
//: [Next](@next)
