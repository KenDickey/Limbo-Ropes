# Limbo-Ropes
Implementation of Ropes (functional strings) in Limbo for the Inferno OS.

Being immutable, ropes are thread-safe.  Ropes are useful, e.g. in text editing, as undo is trivial and typically only small amounts of text are changed in a larger document.

Inferno OS is a simple to use, very portable OS.  Inferno itself compiles to bytecode and runs interpreted or is JIT'ed to native.

Inferno runs hosted on Mac/Win/Linux/.. or native on various ARM/Intel/SPARC/PowerPC hardware (e.g. Nintendo/Android/Raspberry Pi). 

This implementation was done to familiarize myself with the Limbo programming language.

References are to be found in the interface file "rope.m", implementation in "rope.b".

Sample usage is in "test-ropes.b"
