
implement RopeTest;

include "sys.m";
	sys: Sys;

include "rope.m";
	ropes: Ropes;
	Rope: import ropes;

include "draw.m";
	draw: Draw;


numAssertFailures := 0;


RopeTest: module
{
    init:	fn( nil: ref Draw->Context, nil: list of string );
};

init( ctxt: ref Draw->Context, args: list of string )
{
    sys = load Sys Sys->PATH;
    ropes = load Ropes Ropes->PATH;

    testRope: ref Rope;
    testRope = Rope.fromString( "Thus we test ourselves" );

    sys->print( "\n\nVVV Rope Test VVV\n" );

## @@FIXME: Create Unit Tests
## @@FIXME: Totally UN-modular


## QUICK LOOK TESTS

    sys->print( "\nRope string is \"%s\"", testRope.toString() );
    printRopeInfo( testRope );

    sys->print( "\n5th char is w = '%c'\n", testRope.at(5) ) ; # zero based

    sys->print( "\nslice from 5 upto 12 [5..11) is \"%s\"", 
		testRope.slice(5,12).toString() );
    printRopeInfo( testRope.slice(5,12) ) ;

    sys->print( "\nslice from 5 length/size 7 is \"%s\"", 
		testRope.sliceSized(5,7).toString() ) ;    
    printRopeInfo( testRope.sliceSized(5,7) ) ;

    ropeFromChar := Rope.fromChar( 'c' );
    sys->print( "\nRope from char 'c'" ) ;
    printRopeInfo( ropeFromChar ) ;

    thisRope, thatRope, otherRope: ref Rope;
    thisRope = Rope.fromString( "This " ) ;
    thatRope = Rope.fromString( "that" ) ;
    sys->print( "\nJoin \"This \" and \"that\" => \"%s\"",
		thisRope.join( thatRope ).toString() );
    printRopeInfo( thisRope.join( thatRope ) );

    otherRope = Rope.fromString( " the other" );
    sys->print( "\nJoin this that and the other (3 ropes)" ) ;
    printRopeInfo( thisRope.join( thatRope ).join( otherRope ) );

    atPutRope: ref Rope;
    atPutRope = testRope.atPut( 0, 'X' ) ;
    sys->print( "\nRope at 0 put 'X' => \"%s\"", atPutRope.toString() );
    printRopeInfo( atPutRope ) ;

    atPutRope = testRope.atPut( 8, 'r' ) ;
    sys->print( "\nRope at 8 put 'r' => \"%s\"", atPutRope.toString() );
    printRopeInfo( atPutRope ) ;

    atPutRope = testRope.atPut( testRope.length() - 1, 'X' ) ;
    sys->print( "\nRope at %d put 'X' => \"%s\"", testRope.length() - 1, atPutRope.toString() );
    printRopeInfo( atPutRope ) ;

    atPutRope = testRope.atPut( 8, 'r' ) ;
    sys->print( "\nRope at 8 put 'r' => \"%s\"", atPutRope.toString() );
    printRopeInfo( atPutRope ) ;

## TEST SETUP ##
    sys->print( "\n\nTEST SETUP" );

    testString := "1234abcd5678hijk90lm";
    flatRope := Rope.fromString( testString );
    showNamedRope( "flatRope", flatRope );

    subRope := flatRope.sliceSized( 4, 12 );
    showNamedRope( "subRope", subRope ) ;

    concRope1 := subRope.join( Rope.fromString( " new string tail" ) );
    showNamedRope( "concRope1", concRope1 ) ;

    concRope2 := concRope1.join( concRope1 );
    showNamedRope( "concRope2", concRope2 ) ;

    concRope3 := Rope.fromString( "Now is the time " ).join( subRope );
    showNamedRope( "concRope3", concRope3 ) ;

    longFlat  := Rope.fromString( "123456789012345678901234567890" );
    showNamedRope( "longFlat", longFlat ) ;

    shortFlat := Rope.fromString( "short" );
    showNamedRope( "shortFlat", shortFlat ) ;

## TEST ACCESS ##
    sys->print( "\n\nTEST ACCESS" );

    sys->print( "\nflatRope.at(4)   = 'a' ? '%c'", flatRope.at(4) );
    assert( flatRope.at(4) == 'a' );
    sys->print( "\nsubRope.at(1)    = 'b' ? '%c'", subRope.at(1) );
    assert( subRope.at(1) == 'b' );
    sys->print( "\nconcRope1.at(1)  = 'b' ? '%c'", concRope1.at(1) );
    assert( concRope1.at(1) == 'b' );
    sys->print( "\nconcRope1.at(13) = 'n' ? '%c'", concRope1.at(13) );
    assert( concRope1.at(13) == 'n' );
    sys->print( "\nconcRope2.at(4)  = '5' ? '%c'", concRope2.at(4) );
    assert( concRope2.at(4) == '5' );
    sys->print( "\nconcRope2.at(concRope1.length()+4) = '5' ? '%c'",
		 concRope2.at( concRope1.length() + 4 ) );
    assert( concRope2.at( concRope1.length() + 4 ) == '5' );
    sys->print( "\nconcRope3.at(4)  = 'i' ? '%c'", concRope3.at(4) );
    assert( concRope3.at(4) == 'i' );
    sys->print( "\nconcRope3.at(20) = '5' ? '%c'", concRope3.at(20) );
    assert( concRope3.at(20) == '5' );

## TEST MUTATION ##
    sys->print( "\n\nTEST MUTATION" );
#  Can we make a change which makes a difference?

    sys->print( "\nflatRope.atPut( 0, '0' ).toString() == \"0234abcd5678hijk90lm\"" ) ;
    assert( flatRope.atPut( 0, '0' ).toString() == "0234abcd5678hijk90lm" ) ;

    sys->print( "\nflatRope.atPut( flatRope.length() - 1, '0' ).toString() == \"1234abcd5678hijk90l0\"" ) ;
    assert( flatRope.atPut( flatRope.length() - 1, '0' ).toString() == "1234abcd5678hijk90l0"  ) ;

    sys->print( "\nflatRope.atPut( 4, '5' ).toString() == \"12345bcd5678hijk90lm\"" ) ;
    assert( flatRope.atPut( 4, '5' ).toString() == "12345bcd5678hijk90lm"  ) ;

    sys->print( "\nsubRope.atPut( 4, 'e' ).toString() ==  \"abcde678hijk\"" ) ;
    assert( subRope.atPut( 4, 'e' ).toString() ==  "abcde678hijk" ) ;

    sys->print( "\nsubRope.atPut( 0, '0' ).toString() == \"0bcd5678hijk\"" ) ;
    assert( subRope.atPut( 0, '0' ).toString() == "0bcd5678hijk"  ) ;

    sys->print( "\nsubRope.atPut( (subRope.length()-1), '0' ).toString() == \"abcd5678hij0\"" ) ;
    assert( subRope.atPut( (subRope.length() - 1), '0' ).toString() == "abcd5678hij0"  ) ;

    sys->print( "\nconcRope1.atPut( 1, '0' ).toString() ==  \"a0cd5678hijk new string tail\"" ) ;
    assert( concRope1.atPut( 1, '0' ).toString() ==  "a0cd5678hijk new string tail" ) ;

    sys->print( "\nconcRope1.atPut( 19, '0' ).toString() ==  \"abcd5678hijk new st0ing tail\"" ) ;
    assert( concRope1.atPut( 19, '0' ).toString() ==  "abcd5678hijk new st0ing tail"  ) ;

    sys->print( "\nconcRope1.atPut( concRope1.length() -1, '0' ).toString() ==  \"abcd5678hijk new string tai0\"" ) ;
    assert( concRope1.atPut( concRope1.length() -1, '0' ).toString() ==  "abcd5678hijk new string tai0" ) ;

    sys->print( "\nconcRope3.atPut( 1, '0' ).toString() ==   \"N0w is the time abcd5678hijk\"" ) ;
    assert( concRope3.atPut( 1, '0' ).toString() ==   "N0w is the time abcd5678hijk" ) ;

    sys->print( "\nconcRope3.atPut( 19, '0' ).toString() ==   \"Now is the time abc05678hijk\"" ) ;
    assert( concRope3.atPut( 19, '0' ).toString() ==   "Now is the time abc05678hijk" ) ;

    sys->print( "\nconcRope3.atPut( concRope1.length() - 1, '0' ).toString() ==   \"Now is the time abcd5678hij0\"" ) ;
    assert( concRope3.atPut( concRope1.length() - 1, '0' ).toString() ==   "Now is the time abcd5678hij0"  ) ;

## TEST REBALANCE ##
    sys->print( "\n\nTEST REBALANCE" );

    fr1 := Rope.fromString( "12345678901234567890" );
    fr2 := Rope.fromString( "abcdefghijklmnopqrstuvwxyz" );
    t1 := (fr1.join(fr2).join(fr1).join(fr2).join(fr1).join(fr2).join(fr1).join(fr2));
    t2 := (fr1.join(concRope1).join(fr2).join(concRope2).join(fr1)
		.join(fr2).join(fr1).join(fr2).join(concRope3).join(fr1).join(fr2));

    sys->print( "\nassert( t1.depth() == 7 ) " );
    assert( t1.depth() == 7 ) ;

##    sys->print( "\n@@t1.rebalance().depth() == %d ", t1.rebalance().depth() );

    sys->print( "\nassert( t1.rebalance().depth() == 3 ) " );
    assert( t1.rebalance().depth() == 3 ) ;
##    showNamedRope( "#@t1", t1 );
##    showNamedRope( "#@t1.rebalance()", t1.rebalance() );

    sys->print( "\nassert( t1.rebalance().toString() == t1.toString() ) " );
    assert( t1.rebalance().toString() == t1.toString() ) ;

    sys->print( "\nassert( t2.depth() == 11 ) " );
    assert( t2.depth() == 11 ) ;
##    showNamedRope( "t2", t2 );
##    showNamedRope( "t2.rebalance()", t2.rebalance() );

    sys->print( "\nassert( t2.rebalance().depth() == 4 ) " );
    assert( t2.rebalance().depth() == 4 ) ;

    sys->print( "\nassert( t2.rebalance().toString() == t2.toString()) " );
    assert( t2.rebalance().toString() == t2.toString()) ;

##
    if (numAssertFailures > 0)
	sys->print( "\n *** %d ASSERTION FAILURES ***\n", numAssertFailures );
##
    sys->print( "\n\n^^^ End Rope Test ^^^\n\n" );
}

c2s( c: int ) : string 
{
	byteArray := array[] of { byte c } ;
	return string byteArray ;
}


ropeKind( r: ref Rope ) : string 
{
	pick rope := r {
		FlatRope   => return "FlatRope" ;
		SubRope    => return "SubRope" ;
		ConcatRope => return "ConcatRope" ;
	};
}


printRopeInfo( aRope: ref Rope )
{
	sys->print( "\nRope.toString() => \"%s\"", aRope.toString()  );
	printRopeStructureIndent( aRope, 2 ) ;
        sys->print( "\n  Rope.length() => %d", aRope.length() ) ;
        sys->print( "\n  Rope.depth() => %d \n", aRope.depth() ) ;
}


printRopeStructureIndent( aRope: ref Rope, indent: int )
{
	sys->print("\n");
	for (i := 0; i < indent; i++)
		sys->print(" ");
	pick rope := aRope {
		FlatRope   =>
			sys->print( "FlatRope: \"%s\"", rope.s ) ;
		SubRope    =>
			sys->print( "SubRope: \"%s\"", rope.toString() ) ;
		ConcatRope =>
			sys->print( "ConcatRope \"%s\" with parts:", rope.toString() ) ; 
			printRopeStructureIndent( rope.leftRope,  indent + 3 );
			printRopeStructureIndent( rope.rightRope, indent + 3 );
	};
}

showNamedRope( aName: string, aRope: ref Rope )
{
	sys->print( "\n%s:", aName ) ;
	printRopeStructureIndent( aRope, 2 ) ;
}

## Fake unit test support a bit..

assert( shouldBeTrue : int )
{
	if (shouldBeTrue)
	  sys->print( "  :Passed");
	else {
	  numAssertFailures += 1;
	  sys->print( " *** FAILED FAILED FAILED ***" ) ;
	}
}

deny( shouldBeFalse : int )
{
	assert( ~ shouldBeFalse ) ;
}

##		-- E O F --		##
