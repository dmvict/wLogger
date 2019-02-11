(function _PrinterMid_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './PrinterBase.s' );

  let _ = _global_.wTools;

  require( './aChainer.s' );
  require( './aChainingMixin.s' )

  _.include( 'wCopyable' );
  _.include( 'wEventHandler' );

}

//

/**
 * @class wPrinterMid
 */
let _global = _global_;
let _ = _global_.wTools;
let Parent = _.PrinterBase;
let Self = function wPrinterMid( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'PrinterMid';

// --
// routines
// --

function init( o )
{
  let self = this;
  o = o || Object.create( null );

  _.assert( arguments.length === 0 | arguments.length === 1 );

  if( Config.debug )
  if( o.scriptStack === undefined )
  o.scriptStack = _.diagnosticStack([ 2, Infinity ]);

  Parent.prototype.init.call( self,o );

  self.levelSet( self.level );

}

// --
// etc
// --

function levelSet( level )
{
  let self = this;

  Parent.prototype.levelSet.call( self,level );

  level = self[ levelSymbol ];

  self._prefix = _.strDup( self._dprefix || '',level );
  self._postfix = _.strDup( self._dpostfix || '',level );

}

//

function _transformBegin( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( self.onTransformBegin )
  o = self.onTransformBegin( o );

  if( !o )
  return;

  if( !self.verboseEnough() )
  return;

  o = Parent.prototype._transformBegin.call( self, o );

  if( !o )
  return;

  self._laterActualize();

  return o;
}

//

function _transformEnd( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( self.onTransformEnd )
  self.onTransformEnd( o );

  o = Parent.prototype._transformEnd.call( self, o );

  if( !o )
  return;

  return o;
}

// --
// attributing
// --

function _begin( key,val )
{
  let self = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.strIs( key ),'Expects string {-key-}, got',_.strType( key ) );

  if( val === undefined )
  {
    _.assert( 0,'value expected' );
    self._end( key,val );
    return self;
  }

  if( self.attributes[ key ] !== undefined )
  {
    self._attributesStacks[ key ] = self._attributesStacks[ key ] || [];
    self._attributesStacks[ key ].push( self.attributes[ key ] );
  }

  self.attributes[ key ] = val;

  return self;
}

//

function begin()
{
  let self = this;

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let argument = arguments[ a ];

    if( _.objectIs( argument ) )
    {
      for( let key in argument )
      self._begin( key,argument[ key ] )
      return;
    }

    self._begin( argument,1 );
  }

  return self;
}

//

function _end( key,val )
{
  let self = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.strIs( key ) );

  if( val !== undefined )
  _.assert
  (
    val === self.attributes[ key ],
    () => self._attributeError( key, self.attributes[ key ], val )
  );

  if( self._attributesStacks[ key ] )
  {
    self.attributes[ key ] = self._attributesStacks[ key ].pop();
    if( !self._attributesStacks[ key ].length )
    delete self._attributesStacks[ key ];
  }
  else
  {
    delete self.attributes[ key ];
  }

  return self;
}

//

function end()
{
  let self = this;

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let argument = arguments[ a ];

    if( _.objectIs( argument ) )
    {
      for( let key in argument )
      self._end( key,argument[ key ] )
      return;
    }

    self._end( argument )
  }

  return self;
}

//

function _rbegin( key, val )
{
  let self = this;
  let attribute = self.attributes[ key ];

  if( attribute === undefined )
  {
    self._begin( key, 0 );
    attribute = 0;
  }

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.strIs( key ),'Expects string {-key-}, got', () => _.strType( key ) );
  _.assert( _.numberIs( val ),'Expects number {-val-}, got', () => _.strType( val ) );
  _.assert( _.numberIs( attribute ), () => _.args( 'Expects number, but attribute', _.strQuote( key ), 'had value', _.strQuote( attribute ) ) );

  return self._begin( key, val + attribute )
}

//

function rbegin()
{
  let self = this;

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let argument = arguments[ a ];

    if( _.objectIs( argument ) )
    {
      for( let key in argument )
      self._rbegin( key,argument[ key ] )
      return;
    }

    self._rbegin( argument,1 );
  }

  return self;
}

//

function _rend( key, val )
{
  let self = this;
  let attributeStack = self._attributesStacks[ key ];

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.strIs( key ) );
  _.assert( _.numberIs( val ) );

  _.assert
  (
    _.arrayIs( attributeStack ) && _.numberIs( attributeStack[ attributeStack.length-1 ] ),
    () => self._attributeError( key, undefined, val )
  );

  let attribute = attributeStack[ attributeStack.length-1 ];
  val = attribute + val;

  self._end( key, val );

  return self;
}

//

function rend()
{
  let self = this;

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let argument = arguments[ a ];

    if( _.objectIs( argument ) )
    {
      for( let key in argument )
      self._rend( key,argument[ key ] )
      return;
    }

    self._rend( argument )
  }

  return self;
}

//

function _attributeError( key, begin, end )
{
  let self = this;

  debugger;

  return _.err
  (
    '{-begin-} does not have complemented {-end-}' +
    '\nkey : ' + _.toStr( key ) +
    '\nbegin : ' + _.toStr( begin ) +
    '\nend : ' + _.toStr( end ) +
    '\nlength : ' + ( self._attributesStacks[ key ] ? self._attributesStacks[ key ].length : 0 )
  );

}

// --
// verbosity
// --

function verbosityPush( src )
{
  let self = this;

  // debugger;

  if( !_.numberIs( src ) )
  src = src ? 1 : 0;

  _.assert( arguments.length === 1, 'Expects single argument' );

  self._verbosityStack.push( self.verbosity );

  self.verbosity = src;

}

//

function verbosityPop()
{
  let self = this;

  _.assert( arguments.length === 0 );

  // debugger;

  self.verbosity = self._verbosityStack.pop();

}

//

function verbosityReserve( args )
{
  let self = this;

  if( !self.usingVerbosity )
  return Infinity;

  return self._verbosityReserve();
}

//

function _verbosityReserve()
{
  let self = this;

  _.assert( arguments.length === 0 );

  // if( self.attributes.verbosity === undefined )
  // return Infinity;

  if( self.verbosity === null )
  return Infinity;

  return self.verbosity + ( self.attributes.verbosity || 0 ) + 1;
}

//

function verboseEnough()
{
  let self = this;

  _.assert( arguments.length === 0 );

  if( !self.usingVerbosity )
  return true;

  return self._verboseEnough();
}

//

function _verboseEnough()
{
  let self = this;

  _.assert( arguments.length === 0 );

  return self._verbosityReserve() > 0;
}

//

function _verbosityReport()
{
  let self = this;

  console.log( 'logger.verbosity',self.verbosity );
  console.log( 'logger.attributes.verbosity',self.attributes.verbosity );
  console.log( self.verboseEnough() ? 'Verbose enough!' : 'Not enough verbose!'  );

}

//

function _verbositySet( src )
{
  let self = this;

  if( _.boolIs( src ) )
  src = src ? 1 : 0;

  _.assert( arguments.length === 1 );
  _.assert( _.numberIs( src ) );

  src = _.numberClamp( src, 0, 9 );

  let change = self[ verbositySymbol ] !== src;

  self[ verbositySymbol ] = src;

  if( change )
  self.eventGive( 'verbosityChange' );

  return src;
}

// --
// later
// --

function later( name )
{
  let self = this;
  let later = Object.create( null );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( name ) );

  later.name = name;
  later.after = [];
  later.logger = self;
  later.autoFinit = 1;
  later.detonated = 0;
  later.log = function log()
  {
    if( this.logger.verboseEnough )
    this.after.push([ 'log',arguments ]);
  }

  self._mines[ name ] = later;

  return later;
}

//

function _laterActualize()
{
  let self = this;
  let result = Object.create( null );

  for( let m in self._mines )
  {
    let later = self._mines[ m ];
    if( !later.detonated )
    self.laterActualize( later );
  }

  return result;
}

//

function laterActualize( later )
{
  let self = this;

  if( _.strIs( later ) )
  later = self._mines[ later ];

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.mapIs( later ) );

  later.detonated = 1;

  for( let a = 0 ; a < later.after.length ; a++ )
  {
    let after = later.after[ a ];
    self[ after[ 0 ] ].apply( self,after[ 1 ] );
  }

  if( later.autoFinit )
  self.laterFinit( later );

  return self;
}

//

function laterFinit( later )
{
  let self = this;

  if( _.strIs( later ) )
  later = self._mines[ later ];

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.mapIs( later ) );
  _.assert( self._mines[ later.name ] === later );

  Object.freeze( later );
  delete self._mines[ later.name ];

  return self;
}

// --
// relations
// --

let levelSymbol = Symbol.for( 'level' );
let verbositySymbol = Symbol.for( 'verbosity' );

let Composes =
{

  verbosity : 0,
  usingVerbosity : 1,

  onTransformBegin : null,
  onTransformEnd : null,
  // onVerbosity : null,

  attributes : _.define.own( {} ),

}

if( Config.debug )
Composes.scriptStack = null;

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{

  _prefix : '',
  _postfix : '',

  _dprefix : '  ',
  _dpostfix : '',

  _verbosityStack : _.define.own( [] ),

  _attributesStacks : _.define.own( {} ),
  _mines : _.define.own( {} ),

}

let Events =
{
  verbosityChange : 'verbosityChange',
}

let Accessors =
{
  verbosity : 'verbosity',
}

let Forbids =
{
  format : 'format',
  tags : 'tags',
}

// --
// declare
// --

let Proto =
{

  // routine

  init : init,

  // etc

  levelSet : levelSet,
  _transformBegin : _transformBegin,
  _transformEnd : _transformEnd,

  // attributing

  _begin : _begin,
  begin : begin,
  _end : _end,
  end : end,

  _rbegin : _rbegin,
  rbegin : rbegin,
  _rend : _rend,
  rend : rend,

  _attributeError : _attributeError,

  // verbosity

  verbosityPush : verbosityPush,
  verbosityPop : verbosityPop,
  verbosityReserve : verbosityReserve,
  _verbosityReserve : _verbosityReserve,
  verboseEnough : verboseEnough,
  _verboseEnough : _verboseEnough,
  _verbosityReport : _verbosityReport,
  _verbositySet : _verbositySet,

  // later

  later : later,
  _laterActualize : _laterActualize,
  laterActualize : laterActualize,
  laterFinit : laterFinit,

  // relations

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Events : Events,
  Accessors : Accessors,
  Forbids : Forbids,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.assert( Self.prototype.init === init );
_.EventHandler.mixin( Self );

// --
// export
// --

_[ Self.shortName ] = Self;

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();