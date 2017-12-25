/*:
 # LBaC
 # Chapter IX: A Top View
 ## Part 1: Up VS. Down
 The program we have developed so far has a decidedly *bottom-up flavor*. For example, in the case of expression parsing, we began with the lowest level constructs and worked our way up to more complex expressions.
 
 So now, we will start from the bare cradle once again to build a translator for a subset of the KISS language, which we will call TINY. But this time, we will do it in a **top-down fashion**.
 
 ### Top-Level
 Biggest mistake people make in a top-down design is *not starting at the true top.* For our program, we will do it right by looking at the three possible top-level recognizers.
 
 First recognizer is `prog()`, which is the progam itself
 */

/*:
 ### prolog() & epilog()
  `prolog` and `epilog` perform whatever is required to let the program interface with the OS; they will be VERY OS-dependent.
 */
func prolog() {
    emitLine(msg: "WARMST EQU $A01E")
}

func epilog(_ name: Character) {
    emitLine(msg: "DC WARMST")
    emitLine(msg: "END \(name)")
}

/*:
 ### prog()
 This parses and translates a program where `p` stands for `PROGRAM`
 
 Until now, we have been emitting code for a 68000 which runs on SK*DOS and its too late to change... so we will stick to it
 */
func prog() {
    LOOK.match("p")
    let name = LOOK.getName()
    prolog()
    LOOK.match(".")
    epilog(name)
}

/*:
 ### So far...
 There are few things to note here.
 
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
//: [Next](@next)
