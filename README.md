# Whiteplanes

Whiteplane is a whitespace interpreter writen in Swift.

## Whitespace

Whitespace is an esoteric programming language developed by Edwin Brady and Chris Morris at the University of Durham (also developers of the Kaya and Idris programming languages). It was released on 1 April 2003 (April Fool's Day). 
Its name is a reference to whitespace characters.   
Unlike most programming languages, which ignore or assign little meaning to most whitespace characters, the Whitespace interpreter ignores any non-whitespace characters.   
Only spaces, tabs and linefeeds have meaning. 

An interesting consequence of this property is that a Whitespace program can easily be contained within the whitespace characters of a program written in another language, except possibly in languages which depend on spaces for syntax validity such as Python, making the text a polyglot.
The language itself is an imperative stack-based language. The virtual machine on which the programs run has a stack and a heap.   
The programmer is free to push arbitrary-width integers onto the stack (currently there is no implementation of floating point numbers) and can also access the heap as a permanent store for variables and data structures.

### Commands

|IMP|COMMAND|PARAMETER|MNEMONIC|
|:--:|:--:|:--:|:--:|
|[space]|[space]|Number|PUSH|
|[space]|[tab][space]|Number|COPY|
|[space]|[tab][newline]|Number|SLIDE|
|[space]|[newline][space]||DUPLICATE|
|[space]|[newline][tab]||SWAP|
|[space]|[newline][newline]||DISCARD|
|[tab][space]|[space][space]||ADD|
|[tab][space]|[space][tab]||SUB|
|[tab][space]|[space][newline]||MUL|
|[tab][space]|[tab][space]||DIV|
|[tab][space]|[tab][tab]||MOD|
|[tab][tab]|[space]||STORE|
|[tab][tab]|[tab]||RETRIEVE|
|[newline]|[space][space]|Label|REGISTER|
|[newline]|[space][tab]|Label|CALL|
|[newline]|[space][newline]|Label|JUMP|
|[newline]|[tab][space]|Label|TEST ( if push == 0 )|
|[newline]|[tab][tab]|Label|TEST ( if push < 0 )|
|[newline]|[tab][newline]||RETURN|
|[newline]|[newline][newline]||END|
|[tab][newline]|[space][space]||OUTPUT ( character )|
|[tab][newline]|[space][tab]||OUTPUT ( number )|
|[tab][newline]|[tab][space]||INPUT ( character )|
|[tab][newline]|[tab][tab]||INPUT ( number )|

## License
![License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)

(The MIT License)

Copyright © 2016 [Takuya Katsurada](https://github.com/nutcrack)

Permission is hereby granted, free of charge, 
to any person obtaining a copy of this software and 
associated documentation files (the 'Software'), 
to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
