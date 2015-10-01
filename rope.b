
implement Ropes;

include "rope.m" ;

##@@DEBUG
##include "sys.m";
##	sys: Sys;
##@@DEBUG

# Tuning Parameters	
maxRopeDepth:  con 96;  # Rebalance ropes whose depth exceeds this.
meldThreshold: con 17;  # Meld strings shorter than this 
	

Rope.fromString( str: string ) : ref Rope
{
	return ref Rope.FlatRope( str ) ;
}


Rope.toString( r: self ref Rope ) : string
{
	pick rope := r {
		FlatRope => 
			return rope.s ;
			
		SubRope => 
			return (rope.parentRope.toString())
					[ rope.startIndex : rope.startIndex + rope.numChars ] ;
			
		ConcatRope =>
		 ## @@FIXME: do without temps
			return 
				(  rope.leftRope.toString()
				 + rope.rightRope.toString() );
	};
}


Rope.fromChar( char: int ) : ref Rope 
{
	return ref Rope.FlatRope( char2string( char ) ) ;
}


Rope.length( r: self ref Rope ) : int
{
	pick rope := r {
		FlatRope => 
			return len rope.s;
		SubRope => 
			return rope.numChars;
		ConcatRope => 
			return rope.totalChars;
	};
}


Rope.at( r: self ref Rope, index: int ) : int
{
	pick rope := r {
		FlatRope => 
			return rope.s[ index ] ;
		SubRope => 
			return rope.parentRope.at( index + rope.startIndex ) ;;
		ConcatRope =>
		{
			leftLength := rope.leftRope.length();
			if (index <= leftLength)
				return rope.leftRope.at( index );
			else
				return rope.rightRope.at( index - leftLength );
		};
	};

}


Rope.atPut( r: self ref Rope, index: int, unichar: int ) : ref Rope
{
	ropeChar := Rope.fromChar( unichar ) ;
	rLength  := r.length() ;

	if (index == 0) # at start
		return ropeChar.join( r.sliceSized( 1, rLength - 1 ) ) ;

	if (index == rLength)  # at end
		return (r.sliceSized( 0, rLength - 1)).join( ropeChar );

	return ( ((r.sliceSized( 0, index )).join( ropeChar ))
			 .join( r.sliceSized( index+1, rLength - index - 1 ) )
		    );
}


char2string( c: int ) : string
{	#@@ FIXME: must exist somewhere..
	mask := int 16r000000FF;
	byteArray := array[] of { 
		byte (c & mask),
#		byte ((c >>  8) & mask),  ##@@FIXME: Print %s shows "c" but len reports 4
#		byte ((c >>16) & mask),
#		byte ((c >> 24) & mask)
	};
	return string byteArray;
}


Rope.join( leftR: self ref Rope, rightR: ref Rope ) : ref Rope 
{ 
	leftLength  := leftR.length();
	rightLength := rightR.length();
	totalLength := leftLength + rightLength;

	if (leftLength == 0)
		return rightR;

	if (rightLength == 0)
		return leftR;

	if (totalLength <= meldThreshold) # Meld short strings together
		return Rope.fromString( leftR.toString() + rightR.toString() ) ;

	## If left is ConcatRope,
	## left rope has short right child, 
	## and right rope is short,
	## then meld left.right and right.
	pick left := leftR {
	  FlatRope   => ;
	  SubRope    => ;
	  ConcatRope => {
	    if (left.rightRope.length() + rightR.length() <= meldThreshold)
		return ref Rope.ConcatRope( 
			left.leftRope,
			Rope.fromString( 
				left.rightRope.toString()
				+ rightR.toString() ),
			left.depth(),
			totalLength
		);
	  };
	}

	return balanceAsRequired( 
		ref Rope.ConcatRope( 
				 leftR, 
				 rightR,
				 (1 + max( leftR.depth(), rightR.depth() )),
				 totalLength )
	);
}


max( l: int, r: int ) : int  ## @@FIXME: must exist somewhere
{
	if (l < r) return r;
	return l;
}


Rope.slice( r: self ref Rope, startIdx: int, endIdx: int ) : ref Rope 
{	# slice of chars from startIdx to endIdx - 1
	return ref Rope.SubRope( startIdx, endIdx - startIdx, r );
}


Rope.sliceSized( r: self ref Rope, startIdx: int, numChars: int ) : ref Rope
{
	return ref Rope.SubRope( startIdx, numChars, r );
}


Rope.depth( r : self ref Rope ) : int
{
	pick rope := r {
		FlatRope   => return 0; # leaf
		SubRope    => return 0; # leaf
		ConcatRope => return rope.ropeDepth;
	};
}

balanceAsRequired( r: ref Rope ) : ref Rope
{
	if (r.depth() > maxRopeDepth)
		return r.rebalance() ;
	else
		return r ;
}

Rope.rebalance( r: self ref Rope ) : ref Rope
{   ##	Answer a new balanced rope with my data.

	leafNodes := DQueue.new();
	toExamine := DQueue.new();
	toExamine.addLast( r );

	# DEPTH FIRST
	while ( toExamine.size > 0 )
	{
		node := toExamine.removeFirst();
		pick rope := node {
		  FlatRope => 
			leafNodes.addLast( rope );
		  SubRope => 
			leafNodes.addLast( rope );
		  ConcatRope =>
		  {
			toExamine.addFirst( rope.rightRope );
			toExamine.addFirst( rope.leftRope );
		  }
		};
	}
## @@DEBUG
##	printRopeArray( dqueue2array(leafNodes) ) ;

	return mergeRopes( dqueue2array(leafNodes), 0, leafNodes.size - 1 ) ;
}

##printRopeArray( a: array of ref Rope )
##{
##	sys = load Sys Sys->PATH;
##
##	for (i := 0; i < len a; i++)
##	{
##		sys->print( "\n@@" );
##		for (j := 0; j < i; j++) { sys->print( "  " ); }
##		pick rope := a[i] {
##		  FlatRope => 
##			sys->print( "%s", rope.toString() );
##		  SubRope => 
##			sys->print( "%s", rope.toString() );
##		  ConcatRope =>
##		  {  ## should not happen..
##			sys->print( ">>%s\n", rope.leftRope.toString() );
##			for (j := 0; j <= i; j++) { sys->print( "  " ); }
##			sys->print( ">>%s", rope.rightRope.toString() );
##		  }
##		};
##	}
##}



mergeRopes( leafNodes: array of ref Rope, start: int, end: int ) : ref Rope
{  ## Answer a balanced rope
##@@DEBUG
##sys = load Sys Sys->PATH;
##sys->print( "\n@@>> merge start=(%d) end=(%d)", start, end );

	range := end - start;
##sys->print( " range=(%d)", range );
	if (range == 0)
		return leafNodes[start] ;
	
	if (range == 1)
		return leafNodes[start].join(leafNodes[start + 1]) ;
	
	middle := start + (range / 2);  ## Assume '/' is quotient on integers
##sys->print( " middle=(%d)", middle );
	return ( 
		mergeRopes( leafNodes, start, middle )
		   .join( mergeRopes( leafNodes, middle + 1, end) )
	) ;
}


## ============= DQueue code ============

# Doubly Linked List of Ropes (needs parameterized type)
DLList: adt {
	next, prev: cyclic ref DLList;
	rope: ref Rope;

	newDLLHead: fn() : ref DLList; 
	addNext:    fn( dllHead: self ref DLList, rope: ref Rope );
	removePrev: fn( dllHead: self ref DLList ) : ref Rope ;
};

DLList.newDLLHead() : ref DLList 
{  ## Answer a new, empty head node
	newSelf := ref DLList( nil, nil, nil ) ;
	newSelf.next = newSelf;
	newSelf.prev = newSelf;
	return newSelf ;
}

DLList.addNext( dllHead: self ref DLList, rope: ref Rope )
{ 
	newDLink := ref DLList( dllHead.next, dllHead, rope );
#	newDLink.next := dllHead.next;
#	newDLink.prev := dllHead;
#	newLink.rope := rope;
	dllHead.next.prev = newDLink;
	dllHead.next      = newDLink;
}

DLList.removePrev( dllHead: self ref DLList ) : ref Rope
{
	if (dllHead.prev == dllHead)
		return nil;

	last := dllHead.prev;
	dllHead.prev = last.prev;
	dllHead.prev.next = dllHead;

	return last.rope;
}

DQueue: adt {
	head: ref DLList;
	size: int;

	new:         fn() : ref DQueue;
	addFirst:    fn( q: self ref DQueue, r: ref Rope );
	addLast:     fn( q: self ref DQueue, r: ref Rope );
	removeFirst: fn( q: self ref DQueue) : ref Rope;
	removeLast:  fn( q: self ref DQueue) : ref Rope;
	isEmptyP:    fn( q: self ref DQueue ) : int; 
	## ASIDE: LISPism. 'P' stands for "Predicate" and looks like '?'
};

DQueue.new() : ref DQueue
{
	return ref DQueue( DLList.newDLLHead(), 0 ) ;
}

# Convention counter-clockwise (1st is head.prev, last head.next)

DQueue.addFirst( q: self ref DQueue, rope: ref Rope )
{  ## add at head (prev)
	q.head.prev.addNext( rope ) ;
	q.size += 1;
}

DQueue.addLast( q: self ref DQueue, rope: ref Rope )
{  ## add at tail (next)
	q.head.addNext( rope ) ;
	q.size += 1;
}

DQueue.removeFirst( q: self ref DQueue) : ref Rope
{  ## remove from prev
	q.size -= 1;
	return q.head.removePrev() ;
}

DQueue.removeLast( q: self ref DQueue) : ref Rope
{  ## remove from next
	q.size -= 1;
	return q.head.next.next.removePrev() ;
}

DQueue.isEmptyP( q: self ref DQueue ) : int
{
	return (q.size == 0) ;
}

dqueue2array( dq: ref DQueue ) : array of ref Rope
{
	a := array[ dq.size ] of ref Rope;
	dlink := dq.head.prev;
	for ( i := 0; i < dq.size; i++ )
	{
		a[i] = dlink.rope ;
		dlink = dlink.prev ;
	}
	return a ;
}

##			-- E O F --			##
