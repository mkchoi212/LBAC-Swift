![stability-wip](https://img.shields.io/badge/status-work_in_progress-lightgrey.svg)
![stability-done](https://img.shields.io/badge/complete-chapter_1~9-blue.svg)


# LBaC in Swift
This repo is an attempt to learn how compilers work by rewriting Jack W. Crenshaw's [Let's Build a Compiler](http://www.compilers.iecc.com/crenshaw/) in Swift.

## Repo Structure
The original book is divided into 16 chapters and if you haven't noticed already, there are also 16 directories in this repo. Each repo contains the original text (`.txt`) along with a Playground file with the Swift implementation of the code in the corresponding chapter.

- 01
- 02
- 03
	- `tutor3.txt`
	- `03-1.playground`
	- `03-2.playground`
	- ...

Notice that each chapter has multiple playground files, labeled with a `chapter-x.playground`. This is because each chapter has been broken down into mini-chapters. This makes it easier for you to follow along with the book and understand the material by dividing the building process into to small chunks.

## Notes
The original Let's Build a Compiler (LBaC) was written in Turbo Pascal, a very popular language at the time. Pascal is very different from Swift and because of this, "literally" converting Pascal code into Swift won't be "Swifty". 

To make the code as "Swifty" as possible, I have taken the liberty to make some changes in the code.
