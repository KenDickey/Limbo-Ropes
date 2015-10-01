### Ropes: Immutable (a.k.a. functional) strings for Inferno

# Ropes are a high-level representation of text that offers much better 
# performance than strings for common operations, and generally reduce 
# memory allocations and copies, while only entailing a small degradation 
# of less common operations.
 
# More precisely, where a string is represented as a memory buffer, 
# a rope is a tree structure whose leaves are slices of immutable strings.  
# Therefore, concatenation, appending, prepending, substrings, etc. are 
# operations that require only trivial tree manipulation, generally 
# without having to copy memory.  In addition, the tree structure of 
# ropes makes them suitable for undoable operations in text editors where 
# numerous small changes are made to a large piece of text.
#  
# Note that ropes are immutable.  Each operation on a rope returns a new rope.
#
# Because they are immutable, ropes are thread-safe.
# 
# The following operations are algorithmically faster in ropes
# 
# - extracting a subrope is logarithmic (linear in strings);
# - appending/prepending is near-constant time (linear in strings);
# - concatenation is near-constant time (linear in strings);
# - char length is constant-time (linear in strings);
# - access to a character by index is logarithmic (linear in strings);
# 
# ### References
# 
# - http://en.wikipedia.org/wiki/Rope
# - Smalltalk implementation in 
# 	https://github.com/KenDickey/Cuis-Smalltalk-Ropes
# - A Python implementation which uses Ropes 
# 	http://morepypy.blogspot.com/2007/11/ropes-branch-merged.html
# - IBM Java Ropes performance report 
# 	http://www.ibm.com/developerworks/java/library/j-ropes/index.html
# - 'Ropes: an Alternative to Strings' 
# 	http://citeseer.ist.psu.edu/viewdoc/downloaddoi=10.1.1.14.9450&rep=rep1&type=pdf
# - The Mozilla Rust language uses Ropes 
# 	http://static.rust-lang.org/doc/0.5/std/rope.html ;
#   Ropes API 
# 	http://static.rust-lang.org/doc/0.5/std/rope.html#type-rope
  
Ropes: module
{
	PATH: con "rope.dis" ;  ##  "/dis/lib/rope.dis";

	Rope : adt {
		pick {
		  FlatRope => 
			s: string;
		  SubRope => 
			startIndex: int;
			numChars:   int;
			parentRope: ref Rope; 
		  ConcatRope =>
			leftRope:   ref Rope;
			rightRope:  ref Rope;
			ropeDepth:  int;
			totalChars: int;
		  }

	
		fromString: fn( str: string ) : ref Rope ;
		toString: fn( r: self ref Rope ) : string ;
		fromChar: fn( char: int ) : ref Rope ;
		length:	fn( r: self ref Rope ) : int ;
		at:	fn( r: self ref Rope, index: int ) : int ; # Returns s[index]
		atPut:	fn( r: self ref Rope, index: int, unichar: int ) : ref Rope ; 
			# atPut() returns a new Rope instance with new.at(index) == unichar
		join:	fn( leftR: self ref Rope, rightR: ref Rope ) : ref Rope ;
		slice:	fn( r: self ref Rope, startIdx: int, endIdx: int ) : ref Rope ;
		sliceSized: fn( r: self ref Rope, startIdx: int, numChars: int ) : ref Rope ;
	## 	DEBUG
		depth: 	fn( r: self ref Rope ) : int ;
		rebalance: fn( r: self ref Rope ) : ref Rope ;

### string interface ### NYI ###
	# the second arg of the following is a character class
	#    e.g., "a-zA-Z", or "^ \t\n"
	# (ranges indicated by - except in first position;
	#  ^ is first position means "not in" the following class)
	# splitl splits just before first char in class;  (s, "") if no split
	# splitr splits just after last char in class; ("", s) if no split
	# drop removes maximal prefix in class
	# take returns maximal prefix in class

#	splitl:		fn(s, cl: string): (string, string);
#	splitr:		fn(s, cl: string): (string, string);
#	drop:		fn(s, cl: string): string;
#	take:		fn(s, cl: string): string;
#	in:		fn(c: int, cl: string): int;

	# in these, the second string is a string to match, not a class
#	splitstrl:	fn(s, t: string): (string, string);
#	splitstrr:	fn(s, t: string): (string, string);

	# is first arg a prefix of second?
#	prefix:		fn(pre, s: string): int;

#	tolower:	fn(s: string): string;
#	toupper:	fn(s: string): string;

	# string to int returning value, remainder
#	toint:		fn(s: string, base: int): (int, string);
#	tobig:		fn(s: string, base: int): (big, string);
#	toreal:		fn(s: string, base: int): (real, string);

	# append s to end of l
#	append:		fn(s: string, l: list of string): list of string;
#	quoted:		fn(argv: list of string): string;
#	quotedc:		fn(argv: list of string, cl: string): string;
#	unquoted:		fn(args: string): list of string;
	};
};


##			-- E O F --			##
