( function _Resolver_s_( ) {

'use strict';

/**
 * Collection of routines to resolve complex data structures. It takes a complex data structure, traverses it and resolves all strings having inlined special substrings. Use the module to resolve your templates.
  @module Tools/base/Resolver
*/

/**
 * @file Resolver.s.
 */

/**
 * Collection of routines to resolve complex data structures.
 * @namespace Tools( module::Resolver )
 * @memberof module:Tools/base/Resolver
 */

/* screen out :

will
reflector
path
module
opener

*/

/* replace by more genertic :

qualifiedName

*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );
  _.include( 'wLooker' );
  _.include( 'wSelector' );

}

let _global = _global_;
let _ = _global_.wTools;
let Parent = _.Selector;
let Self = _.Resolver = _.Resolver || Object.create( null );

// --
// parser
// --

function strRequestParse( srcStr )
{
  let resolver = this;

  if( resolver._selectorIs( srcStr ) )
  {
    let left, right;
    let splits = _.strSplit( srcStr );

    if( splits.length > 1 )
    debugger;

    for( let s = splits.length - 1 ; s >= 0 ; s-- )
    {
      let split = splits[ s ];
      if( resolver._selectorIs( split ) )
      {
        left = splits.slice( 0, s+1 ).join( ' ' );
        right = splits.slice( s+1 ).join( ' ' );
      }
    }
    let result = _.strRequestParse( right );
    result.subject = left + result.subject;
    result.subjects = [ result.subject ];
    return result;
  }

  let result = _.strRequestParse( srcStr );
  return result;
}

//

function _selectorIs( selector )
{
  if( !_.strIs( selector ) )
  return false;
  if( !_.strHas( selector, '::' ) )
  return false;
  return true;
}

//

function selectorIs( selector )
{
  if( _.arrayIs( selector ) )
  {
    for( let s = 0 ; s < selector.length ; s++ )
    if( this.selectorIs( selector[ s ] ) )
    return true;
  }
  return this._selectorIs( selector );
}

//

function selectorIsComposite( selector )
{

  if( !this.selectorIs( selector ) )
  return false;

  if( _.arrayIs( selector ) )
  {
    for( let s = 0 ; s < selector.length ; s++ )
    if( isComposite( selector[ s ] ) )
    return true;
  }
  else
  {
    return isComposite( selector );
  }

  /* */

  function isComposite( selector )
  {

    let splits = _.strSplitFast
    ({
      src : selector,
      delimeter : [ '{', '}' ],
    });

    if( splits.length < 5 )
    return false;

    splits = _.strSplitsCoupledGroup({ splits : splits, prefix : '{', postfix : '}' });

    if( !splits.some( ( split ) => _.arrayIs( split ) ) )
    return false;

    return true;
  }

}

//

function _selectorShortSplit( selector )
{
  _.assert( !_.strHas( selector, '/' ) );
  let result = _.strIsolateLeftOrNone( selector, '::' );
  _.assert( result.length === 3 );
  result[ 1 ] = result[ 1 ] || '';
  return result;
}

//

function selectorShortSplit( o )
{
  let result;

  _.assertRoutineOptions( selectorShortSplit, o );
  _.assert( arguments.length === 1 );
  _.assert( !_.strHas( o.selector, '/' ) );
  _.sure( _.strIs( o.selector ) || _.strsAreAll( o.selector ), 'Expects string, but got', _.strType( o.selector ) );

  let splits = this._selectorShortSplit( o.selector );

  if( !splits[ 0 ] && o.defaultResourceKind )
  {
    splits = [ o.defaultResourceKind, '::', o.selector ];
  }

  return splits;
}

var defaults = selectorShortSplit.defaults = Object.create( null )
defaults.selector = null
defaults.defaultResourceKind = null;

//

function selectorLongSplit( o )
{
  let result = [];

  if( _.strIs( o ) )
  o = { selector : o }

  _.routineOptions( selectorLongSplit, o );
  _.assert( arguments.length === 1 );
  _.sure( _.strIs( o.selector ) || _.strsAreAll( o.selector ), 'Expects string, but got', _.strType( o.selector ) );

  let selectors = o.selector.split( '/' );

  selectors.forEach( ( selector ) =>
  {
    let o2 = _.mapExtend( null, o );
    o2.selector = selector;
    result.push( this.selectorShortSplit( o2 ) );
  });

  return result;
}

var defaults = selectorLongSplit.defaults = Object.create( null )
defaults.selector = null
defaults.defaultResourceKind = null;

//

function selectorParse( o )
{
  let resolver = this;
  let result = [];

  if( _.strIs( o ) )
  o = { selector : o }

  _.routineOptions( selectorParse, o );
  _.assert( arguments.length === 1 );
  _.sure( _.strIs( o.selector ) || _.strsAreAll( o.selector ), 'Expects string, but got', _.strType( o.selector ) );

  let splits = _.strSplitFast
  ({
    src : o.selector,
    delimeter : [ '{', '}' ],
  });

  splits = _.strSplitsCoupledGroup({ splits : splits, prefix : '{', postfix : '}' });

  if( splits[ 0 ] === '' )
  splits.splice( 0, 1 );
  if( splits[ splits.length-1 ] === '' )
  splits.splice( splits.length-1, 1 );

  splits = splits.map( ( split ) =>
  {
    if( !_.arrayIs( split ) )
    return split;
    _.assert( split.length === 3 )
    if( !this.selectorIs( split[ 1 ] ) )
    return split.join( '' );

    let o2 = _.mapExtend( null, o );
    o2.selector = split[ 1 ];
    return this.selectorLongSplit( o2 );
  });

  splits = _.strSplitsUngroupedJoin( splits );

  if( splits.length === 1 && _.strIs( splits[ 0 ] ) && resolver.selectorIs( splits[ 0 ] ) )
  {
    let o2 = _.mapExtend( null, o );
    o2.selector = splits[ 0 ];
    splits[ 0 ] = resolver.selectorLongSplit( o2 );
  }

  return splits;
}

var defaults = selectorParse.defaults = Object.create( null )
defaults.selector = null
defaults.defaultResourceKind = null;

//

function selectorStr( parsedSelector )
{
  let resolver = this;

  if( _.strIs( parsedSelector ) )
  return parsedSelector;

  let result = '';

  for( let i = 0 ; i < parsedSelector.length ; i++ )
  {
    let inline = parsedSelector[ i ];
    if( _.strIs( inline ) )
    {
      result += inline;
    }
    else
    {
      _.arrayIs( inline )
      result += '{';
      for( let s = 0 ; s < inline.length ; s++ )
      {
        let split = inline[ s ];
        _.assert( _.arrayIs( split ) && split.length === 3 );
        if( s > 0 )
        result += '/';
        result += split.join( '' );
      }
      result += '}';
    }
  }

  return result;
}

//

function selectorNormalize( src )
{
  let resolver = this;

  if( !resolver.selectorIs( src ) )
  return src;

  let parsed = resolver.selectorParse( src );
  let result = resolver.selectorStr( parsed );

  return result;
}

// --
// iterator methods
// --

function _onSelector( selector )
{
  let it = this;
  let rop = it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  if( !_.strIs( selector ) )
  return;

  if( resolver._selectorIs( selector ) )
  {
    return resolver._onSelectorComposite.call( it, selector );
  }

  if( rop.prefixlessAction === 'default' && !it.composite )
  {
    return selector;
  }
  else if( rop.prefixlessAction === 'resolved' || rop.prefixlessAction === 'default' )
  {
    return;
  }
  else if( rop.prefixlessAction === 'throw' || rop.prefixlessAction === 'error' )
  {
    debugger;
    it.iterator.continue = false;
    let err = resolver.errResolving
    ({
      selector,
      rop,
      err : _.ErrorLooking( 'Resource selector should have prefix' ),
    });
    if( rop.prefixlessAction === 'throw' )
    throw err;
    it.dst = err;
    return;
  }
  else _.assert( 0 );

}

//

let _onSelectorComposite = _.select.functor.onSelectorComposite({ isStrippedSelector : 1 });
/* let _onSelectorDown = _.select.functor.onSelectorDownComposite({}); */

//

function _onSelectorDown()
{
  let it = this;
  let rop = it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  resolver._arrayFlatten.call( it );

  if( it.continue && _.arrayIs( it.dst ) && it.src.composite === _.select.composite )
  {

    debugger;

    for( let d = 0 ; d < it.dst.length ; d++ )
    if( _.errIs( it.dst[ d ] ) )
    throw it.dst[ d ];

    it.dst = _.strJoin( it.dst );

  }

}

//

function _onUpBegin()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  debugger;

  if( !it.dstWritingDown )
  return;

  resolver._queryParse.call( it );
  resolver._resourceMapSelect.call( it );

}

//

function _onUpEnd()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  debugger;

  if( !it.dstWritingDown )
  return;

}

//

function _onDownEnd()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  if( !it.dstWritingDown )
  return;

  resolver._functionStringsJoinDown.call( it );

  resolver._mapsFlatten.call( it );
  resolver._mapValsUnwrap.call( it );
  resolver._arrayFlatten.call( it );
  resolver._singleUnwrap.call( it );

}

//

function _onQuantitativeFail( err )
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  debugger;

  let result = it.dst;
  if( _.mapIs( result ) )
  result = _.mapVals( result );
  if( _.arrayIs( result ) )
  {
    let isString = 1;
    if( result.every( ( e ) => _.strIs( e ) ) )
    isString = 1;
    else
    result = result.map( ( e ) =>
    {
      if( _.strIs( e ) )
      return e;
      if( _.strIs( e.qualifiedName ) )
      return e.qualifiedName;
      isString = 0
    });

    if( isString )
    if( result.length )
    err = _.err( err, '\n', 'Found : ' + result.join( ', ' ) );
    else
    err = _.err( err, '\n', 'Found nothing' );
  }

  throw err;
}

//

function _arrayFlatten()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;
  let currentModule = it.currentModule;

  _.assert( _.mapIs( rop ) );

  if( !rop.arrayFlattening || !_.arrayIs( it.dst ) )
  return;

  it.dst = _.arrayFlattenDefined( it.dst );

}

//

function _arrayWrap( result )
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  if( !rop.arrayWrapping )
  return;

  if( !_.mapIs( it.dst ) )
  it.dst = _.arrayAs( it.dst );

}

//

function _mapsFlatten()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  if( !rop.mapFlattening || !_.mapIs( it.dst ) )
  return;

  it.dst = _.mapsFlatten([ it.dst ]);

}

//

function _mapValsUnwrap()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  if( !rop.mapValsUnwrapping )
  return;
  if( !_.mapIs( it.dst ) )
  return;
  if( !_.all( it.dst, ( e ) => _.instanceIs( e ) || _.primitiveIs( e ) ) )
  return;

  it.dst = _.mapVals( it.dst );
}

// //
//
// function _mapValsUnwrap2( result )
// {
//   if( !o.mapValsUnwrapping )
//   return result
//   if( !_.mapIs( result ) )
//   return result;
//   if( !_.all( result, ( e ) => _.instanceIs( e ) || _.primitiveIs( e ) ) )
//   return result;
//   return _.mapVals( result );
// }

//

function _singleUnwrap()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  if( !rop.singleUnwrapping )
  return;

  if( _.any( it.dst, ( e ) => _.mapIs( e ) || _.arrayIs( e ) ) )
  return;

  if( _.mapIs( it.dst ) )
  {
    if( _.mapKeys( it.dst ).length === 1 )
    it.dst = _.mapVals( it.dst )[ 0 ];
  }
  else if( _.arrayIs( it.dst ) )
  {
    if( it.dst.length === 1 )
    it.dst = it.dst[ 0 ];
  }

}

//

function _queryParse()
{
  let it = this;
  let rop = it.resolveOptions;
  let resolver = rop.Resolver;

  if( !it.selector )
  return;

  let splits = resolver.selectorShortSplit
  ({
    selector : it.selector,
    defaultResourceKind : rop.defaultResourceKind,
  });

  it.parsedSelector = Object.create( null );
  it.parsedSelector.kind = splits[ 0 ];

  if( !it.parsedSelector.kind )
  {
    if( splits[ 1 ] !== undefined )
    it.parsedSelector.kind = null;
  }

  it.parsedSelector.full = splits.join( '' );
  it.selector = it.parsedSelector.name = splits[ 2 ];

}

//

function _resourceMapSelect()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  let resolver = rop.Resolver;

  debugger;

  if( !it.selector )
  return;

  debugger;

  let kind = it.parsedSelector.kind;

  if( kind === '' || kind === null )
  {
  }
  else if( kind === 'f' )
  {

    it.isFunction = it.selector;
    if( it.selector === 'strings.join' )
    {
      resolver._functionStringsJoinUp.call( it );
    }
    else _.sure( 0, 'Unknown function', it.parsedSelector.full );

  }
  else
  {
    debugger;
    throw _.ErrorLooking( 'Unknown kind of resource', _.strQuote( it.parsedSelector.full ) );
  }

}

// --
// function
// --

function _functionStringsJoinUp()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;
  // let sop = it.selectOptions; // xxx

  _.sure( !!it.down, () => it.parsedSelector.full + ' expects context to join it' );

  it.src = [ it.src ];
  it.src[ functionSymbol ] = it.selector;

  it.isFunction = it.selector;
  it.selector = 0;

  // sop.selectorChanged.call( it );
  it.selectorChanged();
  it.srcChanged();

}

//

function _functionStringsJoinDown()
{
  let it = this;
  let rop = it.resolveOptions ? it.resolveOptions : it.selectMultipleOptions.iteratorExtension.resolveOptions;

  if( !_.arrayIs( it.src ) || !it.src[ functionSymbol ] )
  return;

  debugger;
  if( _.arrayIs( it.dst ) && it.dst.every( ( e ) => _.arrayIs( e ) ) )
  {
    it.dst = it.dst.map( ( e ) => e.join( ' ' ) );
  }
  else
  {
    it.dst = it.dst.join( ' ' );
  }

}

// --
// err
// --

function errResolving( o )
{
  let resolver = this;
  _.assertRoutineOptions( errResolving, arguments );
  _.assert( arguments.length === 1 );
  debugger;
  return _.err( 'Failed to resolve', _.color.strFormat( o.selector, 'path' ), '\n', o.err );
}

errResolving.defaults =
{
  selector : null,
  rop : null,
  err : null,
}

//

function errResolvingThrow( o )
{
  let resolver = this;
  _.assertRoutineOptions( errResolvingThrow, arguments );
  _.assert( arguments.length === 1 );
  if( o.missingAction === 'undefine' )
  return;

  debugger;

  let err = resolver.errResolving
  ({
    selector : o.selector,
    rop : o.rop,
    err : o.err,
  });

  if( o.missingAction === 'throw' )
  throw err;
  else
  return err;

}

errResolvingThrow.defaults =
{
  missingAction : null,
  selector : null,
  rop : null,
  err : null,
}

// --
// resolve
// --

function resolve_pre( routine, args )
{
  let o = args[ 0 ];

  _.routineOptions( routine, args );

  if( o.visited === null )
  o.visited = [];

  if( o.Resolver === null )
  o.Resolver = Self;

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );
  _.assert( _.arrayHas( [ 'undefine', 'throw', 'error' ], o.missingAction ), 'Unknown value of option missing action', o.missingAction );
  _.assert( _.arrayHas( [ 'default', 'resolved', 'throw', 'error' ], o.prefixlessAction ), 'Unknown value of option prefixless action', o.prefixlessAction );
  _.assert( _.arrayIs( o.visited ) );
  _.assert( !o.defaultResourceKind || !_.strHas( o.defaultResourceKind, '*' ), () => 'Expects non glob {-defaultResourceKind-}, but got ' + _.strQuote( o.defaultResourceKind ) );

  return o;
}

//

function resolve_body( o )
{
  let resolver = this;

  _.assert( !!resolver._resolveAct );
  _.assert( o.prefixlessAction === 'default' || o.defaultResourceKind === null, 'Prefixless action should be "default" if default resource is provided' );

  let result = resolver._resolveAct( o );

  if( result === undefined )
  {
    result = resolver.errResolving
    ({
      selector : o.selector,
      rop : o,
      err : _.ErrorLooking( o.selector, 'was not found' ),
    })
  }

  if( _.errIs( result ) )
  {
    return resolver.errResolvingThrow
    ({
      missingAction : o.missingAction,
      selector : o.selector,
      rop : o,
      err : result,
    });

  }

  let it =
  {
    dst : result,
    resolveOptions : o,
  }

  resolver._mapsFlatten.call( it );
  resolver._mapValsUnwrap.call( it );
  resolver._singleUnwrap.call( it );
  resolver._arrayWrap.call( it );

  return it.dst;
}

resolve_body.defaults =
{

  src : null,
  selector : null,
  defaultResourceKind : null,
  prefixlessAction : 'resolved',
  missingAction : 'throw',
  visited : null,
  singleUnwrapping : 1,
  mapValsUnwrapping : 1,
  mapFlattening : 1,
  arrayWrapping : 0,
  arrayFlattening : 1,
  preservingIteration : 0,
  Resolver : null,

  iteratorExtension : null,
  iterationExtension : null,
  iterationPreserve : null,

}

let resolve = _.routineFromPreAndBody( resolve_pre, resolve_body );
let resolveMaybe = _.routineFromPreAndBody( resolve_pre, resolve_body );

var defaults = resolveMaybe.defaults;
defaults.missingAction = 'undefine';

//

function _resolveAct( o )
{
  let resolver = this;
  let result;

  _.assert( arguments.length === 1 );
  _.assert( _.arrayIs( o.visited ) );

  /* */

  try
  {

    o.iteratorExtension = o.iteratorExtension || Object.create( null );
    if( o.iteratorExtension.isFunction === undefined )
    o.iteratorExtension.resolveOptions = o;

    o.iterationExtension = o.iterationExtension || Object.create( null );

    o.iterationPreserve = o.iterationPreserve || Object.create( null );
    if( o.iterationPreserve.isFunction === undefined )
    o.iterationPreserve.isFunction = null;

    result = _.select
    ({

      src : o.src,
      selector : o.selector,
      preservingIteration : o.preservingIteration,
      missingAction : o.missingAction,

      onSelector : resolver._onSelector,
      onSelectorDown : resolver._onSelectorDown,
      onUpBegin : resolver._onUpBegin,
      onUpEnd : resolver._onUpEnd,
      onDownEnd : resolver._onDownEnd,
      onQuantitativeFail : resolver._onQuantitativeFail,

      iteratorExtension : o.iteratorExtension,
      iterationExtension : o.iterationExtension,
      iterationPreserve : o.iterationPreserve,

    });

  }
  catch( err )
  {
    // debugger;
    throw resolver.errResolving
    ({
      selector : o.selector,
      rop : o,
      err : err,
    });
  }

  return result;
}

var defaults = _resolveAct.defaults = Object.create( resolve.defaults )

// --
// declare
// --

let functionSymbol = Symbol.for( 'function' );
let Extend =
{

  name : 'wResolver',
  shortName : 'Resolver',

  // parser

  strRequestParse,

  _selectorIs,
  selectorIs,
  selectorIsComposite,
  _selectorShortSplit,
  selectorShortSplit,
  selectorLongSplit,
  selectorParse,
  selectorStr,
  selectorNormalize,

  // handler

  _onSelector,
  _onSelectorComposite,
  _onSelectorDown,
  _onUpBegin,
  _onUpEnd,
  _onDownEnd,
  _onQuantitativeFail,

  //

  _arrayFlatten,
  _arrayWrap,
  _mapsFlatten,
  _mapValsUnwrap,
  _singleUnwrap,

  _queryParse,
  _resourceMapSelect,

  // function

  _functionStringsJoinUp,
  _functionStringsJoinDown,

  // err

  errResolving,
  errResolvingThrow,

  // resolve

  resolve,
  resolveMaybe,
  _resolveAct,

}

_.mapExtend( Self, Extend );

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _;

})();
