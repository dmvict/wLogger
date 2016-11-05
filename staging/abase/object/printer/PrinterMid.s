(function _PrinterMid_s_() {

'use strict';

var Chalk;
var isBrowser = true;
if( typeof module !== 'undefined' )
{

  isBrowser = false;

  if( typeof wPrinterBase === 'undefined' )
  require( './PrinterBase.s' )

  try
  {
    require( 'wColor' );
  }
  catch( err )
  {
  }

}

//

var _ = wTools;
var Parent = wPrinterBase;
var Self = function wPrinterMid()
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

var init = function( o )
{
  var self = this;

  Parent.prototype.init.call( self,o );

}

//

var _rgbToCode = function( rgb )
{
  var r = rgb[ 0 ];
  var g = rgb[ 1 ];
  var b = rgb[ 2 ];

  var ansi = 30 + ( ( Math.round( b ) << 2 ) | (Math.round( g ) << 1 ) | Math.round( r ) );

  return ansi;
}

//

var _onStrip = function( strip )
{
  var allowedKeys = [ 'bg','background','fg','foreground' ];
  var parts = strip.split( ' : ' )
  if( parts.length === 2 )
  {
    if( allowedKeys.indexOf( parts[ 0 ] ) === -1 )
    return;
    return parts;
  }
}

//

var colorForegroundGet = function()
{
  var self = this;
  return self.foregroundColor;
}

//

var colorBackgroundGet = function()
{
  var self = this;
  return self.backgroundColor;
}

//

var _writeDoingBrowser = function( str )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var result = [ '' ];

  var splitted = _.strExtractStrips( str, { onStrip : self._onStrip } );
  // if( splitted.length === 1 && !self._isStyled )
  // {
  //   if( !_.arrayIs( splitted[ 0 ] ) )
  //   return splitted;
  // }

  for( var i = 0; i < splitted.length; i++ )
  {
    if( _.arrayIs( splitted[ i ] ) )
    {
      var style = splitted[ i ][ 0 ];
      var color = splitted[ i ][ 1 ];

      if( style === 'foreground')
      {
        if( color === 'default' )
        self.foregroundColor = null;
        else
        self.foregroundColor = _.colorFrom( color );
      }
      else if( style === 'background')
      {
        if( color === 'default' )
        self.backgroundColor = null;
        else
        self.backgroundColor = _.colorFrom( color );
      }
      if( !self.foregroundColor && !self.backgroundColor )
      self._isStyled = 0;
      else if( !!self.foregroundColor | !!self.backgroundColor )
      self._isStyled = 1;
    }
    else
    {
      if( self._isStyled )
      {
        result[ 0 ] += `%c${ splitted[ i ] }`;
        result.push( `color:${ _.colorToRgbHtml( self.foregroundColor ) };background:${ _.colorToRgbHtml( self.backgroundColor ) };` );
      }
      else
      {
        result[ 0 ] +=  splitted[ i ];
      }
    }
  }

  if( !result[ 0 ].length )
  return [];
  return result;
}

//

var _writeDoingChalk = function( str )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var ColorMap =
  {
    // 'invisible'   : [ 0.0,0.0,0.0,0.0 ],
    // 'transparent' : [ 1.0,1.0,1.0,0.5 ],
    'white'       : [ 1.0,1.0,1.0 ],
    'black'       : [ 0.0,0.0,0.0 ],
    'red'         : [ 1.0,0.0,0.0 ],
    'green'       : [ 0.0,1.0,0.0 ],
    'blue'        : [ 0.0,0.0,1.0 ],
    'yellow'      : [ 1.0,1.0,0.0 ],
  }

  if( !self._colorTable )
  {
    self._colorTable = [];
    for( var key in ColorMap  )
    self._colorTable[ key ] = self._rgbToCode( ColorMap[ key ] );
  }

  var result = '';

  var splitted = _.strExtractStrips( str, { onStrip : self._onStrip } );

  for( var i = 0; i < splitted.length; i++ )
  {
    if( _.strIs( splitted[ i ] ) )
    result += splitted[ i ];
    else
    {
      var style = splitted[ i ][ 0 ];
      var color = splitted[ i ][ 1 ];

      if( color && color!='default' )
      {
        if( self._colorTable[ color ] )
        color = self._colorTable[ color ];
        else
        color = self._rgbToCode( _.colorFrom( color ) );
      }

      if( style === 'foreground')
      {
        if( color !== 'default' )
        {
          self.foregroundColor = color;
          result+= `\x1b[${ self.foregroundColor }m`;
        }
        else
        {
          result+= `\x1b[39m`;
        }
      }
      else if( style === 'background' )
      {
        if( color !== 'default' )
        {
          self.backgroundColor = color;
          result+= `\x1b[${ self.backgroundColor + 10 }m`;
        }
        else
        {
          result+= `\x1b[49m`;
        }
      }
    }
  }

  return [ result ];
}

//

var writeDoing = function( args )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var optionsForStr =
  {
    linePrefix : self._prefix,
    linePostfix : self._postfix,
  }

  var result = _.strConcat.apply( optionsForStr,args );

  if( !isBrowser )
  result = self._writeDoingChalk( result );
  else
  result = self._writeDoingBrowser( result );

  return result;
}

//

var symbolForLevel = Symbol.for( 'level' );
var levelSet = function( level )
{
  var self = this;

  _.assert( isFinite( level ) );

  Parent.prototype.levelSet.call( self,level );

  var level = self[ symbolForLevel ];

  self._prefix = _.strTimes( self._dprefix,level );
  self._postfix = _.strTimes( self._dpostfix,level );

  // self.format.level = level;
  // self.format.prefix.current = _.strTimes( self.format.prefix.up,level );
  // self.format.postfix.current = _.strTimes( self.format.postfix.up,level );

}

//

var topic = ( function()
{

  // var Chalk;

  return function topic()
  {
    var self = this;

    debugger;
    //throw _.err( 'not tested' );

    var s = _.str.apply( _,arguments );

    if( Chalk === undefined && typeof module !== 'undefined' )
    try
    {
      Chalk = require( 'chalk' );
    }
    catch( err ) 
    {
      Chalk = null;
    }

    if( Chalk )
    s = Chalk.bgWhite( Chalk.black( s ) );

    this.log();
    this.log( s );
    this.log();

    return s;
  }

})();

// --
// var
// --

// var format =
// {
//   level : 0,
//   prefix :
//   {
//     current : '',
//     up : '  ',
//     down : [ 2,0 ]
//   },
//   postfix :
//   {
//     current : '',
//     up : '',
//     down : ''
//   }
// }

// --
// relationships
// --

var Composes =
{

  _prefix : '',
  _postfix : '',

  _dprefix : '  ',
  _dpostfix : '',

  foregroundColor : null,
  backgroundColor : null,
  _colorTable : null,
  _isStyled : 0

}

var Aggregates =
{
}

var Associates =
{
}

// --
// prototype
// --

var Proto =
{

  // routine

  init : init,

  writeDoing : writeDoing,
  _writeDoingChalk : _writeDoingChalk,
  _writeDoingBrowser : _writeDoingBrowser,
  _rgbToCode : _rgbToCode,
  _onStrip : _onStrip,
  colorForegroundGet : colorForegroundGet,
  colorBackgroundGet : colorBackgroundGet,
  levelSet : levelSet,

  topic : topic,

  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,

}

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

//

_.accessor
({
  object : Self.prototype,
  combining : 'rewrite',
  names :
  {
    level : 'level',
    foregroundColor : 'foregroundColor',
    backgroundColor : 'backgroundColor',
  }
});

// export

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

_global_[ Self.name ] = wTools.PrinterMid = Self;

return Self;

})();
