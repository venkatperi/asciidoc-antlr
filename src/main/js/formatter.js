const { Utils } = require( 'antlr4' );
const { ErrorNode, TerminalNode } = require( 'antlr4/tree/Tree' );
const { RuleContext } = require( 'antlr4/RuleContext' );
const { INVALID_ALT_NUMBER } = require( 'antlr4/atn/ATN' );

function escapeWhitespace( s, escapeSpaces ) {
  s = s.replace( /\t/g, "\\t" )
    .replace( /\n/g, "\\n" )
    .replace( /\r/g, "\\r" );
  if ( escapeSpaces ) {
    s = s.replace( " ", "\u00B7" );
  }
  return s;
}

const toStringTree = function( tree, ruleNames, recog ) {
  if ( !tree ) return null;

  if ( ruleNames && !Array.isArray( ruleNames ) && ruleNames.ruleNames ) {
    recog = ruleNames;
    ruleNames = null;
  }

  if ( recog && recog.ruleNames ) {
    ruleNames = recog.ruleNames;
  }

  if ( !ruleNames ) {
    throw new Error( "Either ruleNames or recog must be set" );
  }

  var s = getNodeText( tree, ruleNames );
  s = Utils.escapeWhitespace( s, false );
  var c = tree.getChildCount();
  if ( c === 0 ) {
    return s;
  }
  var res = "(" + s + ' ';
  if ( c > 0 ) {
    s = toStringTree( tree.getChild( 0 ), ruleNames );
    res = res.concat( s );
  }

  for ( var i = 1; i < c; i++ ) {
    s = toStringTree( tree.getChild( i ), ruleNames );
    res = res.concat( ' ' + s );
  }
  res = res.concat( ")" );
  return res;
};

const toAsciiTree = function( tree, recog, prefix = "", isTail = true ) {
  if ( !tree ) return null;
  let ruleNames = null;

  if ( recog && recog.ruleNames ) {
    ruleNames = recog.ruleNames;
  }

  if ( !ruleNames ) {
    throw new Error( "Either ruleNames or recog must be set" );
  }

  let childCount = tree.getChildCount();

  let name = escapeWhitespace( getNodeText( tree, recog ), false );
  let res = [];
  res.push( prefix );
  res.push( isTail ? "└" : "├" );
  res.push( name );
  res.push( "\n" );

  for ( let i = 0; i < childCount; i++ ) {
    let p = prefix + ( isTail ? " " : "│" );
    res.push( toAsciiTree( tree.getChild( i ), recog, p,
      i < childCount - 1 ? false : true ) );
  }
  return res.join( '' );
};

const toJSON = function( tree, recog, opts = {} ) {
  let obj = toObject( tree, recog, opts );
  return JSON.stringify( obj, null, opts.noSpace ? null : 2 );
}

const toObject = function( tree, recog, opts = {} ) {
  if ( !tree ) return null;
  let ruleNames = null;

  if ( !recog ) {
    throw new Error( "No recognizer?" );
  }

  let res = {};
  res[ opts.name || 'name' ] = escapeWhitespace(
    getNodeText( tree, recog ), false );

  let childCount = tree.getChildCount();
  if ( childCount > 0 ) {
    let children = res[ opts.children || 'children' ] = [];
    for ( let i = 0; i < childCount; i++ ) {
      children.push( toObject( tree.getChild( i ), recog ) );
    }
  }

  return res;
};

const getNodeText = function( t, ruleNames, recog ) {
  if ( !t ) return null;
  if ( ruleNames && !Array.isArray( ruleNames ) && ruleNames.ruleNames ) {
    recog = ruleNames;
    ruleNames = null;
  }

  if ( recog && recog.ruleNames ) {
    ruleNames = recog.ruleNames;
  }

  if ( ruleNames !== null ) {
    if ( t instanceof RuleContext ) {
      var altNumber = t.getAltNumber();
      if ( altNumber != INVALID_ALT_NUMBER ) {
        return ruleNames[ t.ruleIndex ] + ":" + altNumber;
      }
      return ruleNames[ t.ruleIndex ];
    } else if ( t instanceof ErrorNode ) {
      return t.toString();
    } else if ( t instanceof TerminalNode ) {
      if ( t.symbol !== null ) {
        let s = t.symbol;
        return `[${recog.symbolicNames[s.type]} ${s.line}:${s.column}] ${s.text}`;
      }
    }
  }

  // no recog for rule names
  var payload = t.getPayload();
  if ( payload instanceof Token ) {
    return payload.text;
  }
  return t.getPayload().toString();
};

module.exports = {
  toStringTree: toStringTree,
  toAsciiTree: toAsciiTree,
  toJSON: toJSON
}
