
if( typeof module !== 'undefined' )
require( '../staging/abase/object/printer/printer/Logger.s' );
//require( 'wLogger' );

var _ = wTools;
var l1 = new wLogger({ output : null });
var l2 = new wLogger({ output : null });

l1.inputFrom( console );
l2.inputFrom( console );

l1._dprefix = '+';
l2._dprefix = '-';

l1.up( 2 );
l2.up( 3 );

console.log( 'aa\nbb' );
l1.log( 'cc\ndd' );
l2.log( 'ee\nff' );
