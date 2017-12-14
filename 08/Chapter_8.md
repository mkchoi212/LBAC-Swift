# A little breather...

In this chapter, we won't be writing any code. Instead we will look back to what we have done so far and discuss what we will do in the future!

I highly recommend that you read the original text `tutor8.txt`. But if you don't have time and want a **tldr** version of it, here it is!

## So far...
we have covered the parsing / translation of 

- Arithmetic / Boolean expressions
- Combinations connected by releational oeprators
- Some control constructs

Through the process, we heavily relied on the KISS philosophy - *keep it simple, stupid!* - and hope by now you realize how simple making a compiler can be! There are for sure really complicated areas of compiler theory but know that you can just politely sidestep those areas and still be able to make a fully functioning compiler. 

At this point, we have many of the makings of a real compiler. All we have to do is define the language by picking up the small, missing pieces.

## In the future...
we will cover the following items
- Procedure calls with/without parameters
- Local/global vars
- Types
- Arrays
- Strings
- User-defined types/structs
- Tree-structured parsers
- Optimization ⚡

If you think the series have been easy so far... guess what?? 

>  **IT WILL REMAIN EASY BECAUSE THERE ARE NO HARD PARTS 🎉**🎉🎉

Above are the constructs we will build. But here are the two languages we will build in future installments

### TINY
A minimal language on the order of Tiny BASIC or Tiny C. It won't be very practical, but  it will have enough power to let you write and run real programs

### KISS 
KISS is intended to be a systems programming language. It won't have strong typing or fancy data structures, but it will support most of the things I want to do with a higher-order language, except perhaps writing compilers.

## Cool. But why do textbooks make it seem so hard?
Good question. Here are some of my guesses

1. Limited RAM
  - In 1981, Brinch Hansen tried to write a Pascal compiler for a PC with a 64K system.
  - He had to squeeze the compiler into the RAM some how...
2. Batch Processing
  - Back then, turnaround time was measured in hours or days...
3. Large Programs
  - Early compilers were designed to handle large programs.. essentially infinite ones
4. Emphasis on Efficiency
5. Limited Instruction Sets
6. Desire for generality


## For the doubters out there 🤷
You may be thinking

> Q.) The code that we have been writing generates really really inefficient code. I have a feeling that the code our compiler produces is going to be so slow it won't be practical… 

You are right. But note that we have been concentrating on writing tight code without trying to introduce new complexities. But know this. 

> **A.) USING THE TECHNIQUES WE'VE USED HERE,  IT IS POSSIBLE TO BUILD A PRODUCTION-QUALITY, WORKING COMPILER WITHOUT ADDING A LOT OF COMPLEXITY TO WHAT WE'VE ALREADY DONE.**

## So?
Well? Let's get back to building a compiler in Swift and finish the job! 😁😁😁
