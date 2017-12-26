<p align="center">
     <img src="./assets/header.png">
    <h3 align="center">LBAC Swift</h3>
<p align="center">
    "Let's Build a Compiler" translated to Swift Playgrounds
    <br>
    <br>
    <img src="https://img.shields.io/badge/complete-chapter_1~10-blue.svg">
    <img src="https://img.shields.io/badge/status-work_in_progress-lightgrey.svg">
  </p>
</p>
<br>

This repo is an attempt to learn how compilers work by translating Jack W. Crenshaw's [Let's Build a Compiler](http://www.compilers.iecc.com/crenshaw/) book into Swift Playgrounds.

## 🗺️ How to Navigate
The original book is divided into 16 chapters and if you haven't noticed already, there are also 16 Playground files in this repo. 

**Each Playground file represents a chapter in the book**. However, because fitting an entire chapter into a single Playground file would be impractical, each chapter has been divided into several "Parts".

### .playground Structure

A `.playground` file is actually composed of *three* directories.

1. `Parts`  - individual parts of a book resides in
2. `Sources` - `Cradle.swift`, which contains all the boilerplate code used throughout the book is contained here
3. `Resource` - the original LBaC text file `tutor(n).txt` , is contained here

> If you can't seem to find these directories after opening your `.playground` file, press `⌘ + 0` to show the Navigator (left panel).

## ⚠️ Notes
- The original Let's Build a Compiler (LBaC) was written in Turbo Pascal, a very popular language at the time. Pascal is very different from Swift and because of this, "literally" converting Pascal code into Swift is quite unnatural.
- To make the code as "Swifty" as possible, I have taken the liberty to make some changes in the code. Please feel free to offer suggestions on making the code even "Swifty-er"
- This has turned out to be more time consuming than I have imagined in the beginning. Therefore, **out of the 16 chapters, 10 have been completed so far**; feel free to continue on from where I have left off 🏃‍♂️


## ✋ Contributing

This is an open source project so feel free to contribute by

- Opening an [issue](https://github.com/mkchoi212/LBAC-Swift/issues/new)
- Sending me feedback via [email](mailto://mkchoi212@icloud.com)
- Or [tweet](https://twitter.com/Bananamlkshake2) at me!
