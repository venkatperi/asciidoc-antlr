const antlr4 = require( 'antlr4' );

function AbstractAsciidocLexer( input ) {
  antlr4.Lexer.call( this, input );
  return this;
}

AbstractAsciidocLexer.prototype = Object.create( antlr4.Lexer.prototype );

AbstractAsciidocLexer.prototype.isFirstSection = true;

AbstractAsciidocLexer.prototype.isBOL = true;

AbstractAsciidocLexer.prototype.tokenQueue = [];
AbstractAsciidocLexer.prototype.getDelimBoundaryType = function( str ) {
  let proto = Object.getPrototypeOf( this );
  switch ( str ) {
    case "|===":
      return proto.BLOCK_TABLE_START;

    case "--":
      return proto.BLOCK_ANON_START;

    case "```":
      return proto.BLOCK_FENCED_START;

    case "////":
      return proto.BLOCK_COMMENT_START;

    case "====":
      return proto.BLOCK_EXAMPLE_START;

    case "----":
      return proto.BLOCK_LISTING_START;

    case "....":
      return proto.BLOCK_LITERAL_START;

    case "++++":
      return proto.BLOCK_PASS_START;

    case "****":
      return proto.BLOCK_SIDEBAR_START;

    case "____":
      return proto.BLOCK_VERSE_START;
  }

  return -1;
}

AbstractAsciidocLexer.prototype.isDelimBlockStart = function() {
  let text = this.text.trim();
  let len = text.length;
  if ( len === 0 ) return false;

  let ch = text[ 0 ];
  let repeating = false;
  if ( len >= 4 ) {
    repeating = true;
    for ( let i = 1; i < len; i++ ) {
      if ( ch != text[ i ] ) {
        repeating = false;
        break;
      }
    }
  }

  let str = repeating ? text.substr( 0, 4 ) : text;
  return this.getDelimBoundaryType( str ) > 0;
}

AbstractAsciidocLexer.prototype.startDelimBlock = function() {
  let proto = Object.getPrototypeOf( this );
  let text = this.text.trim();
  if ( text.startsWith( "```" ) )
    text = "```";
  this.delimBlockBoundary = text;
  let s = text.length > 4 ? text.substr( 0, 4 ) : text;
  this.type = this.getDelimBoundaryType( s );
  this.pushMode( proto.DELIM_CONTENT );
}

AbstractAsciidocLexer.prototype.isDelimBlockEnd = function() {
  return this.text.trim() === this.delimBlockBoundary;
}

AbstractAsciidocLexer.prototype.emitType = function( type, text ) {
  var t = this._factory.create( this._tokenFactorySourcePair, type,
    text || this._text, this._channel, this._tokenStartCharIndex, this
    .getCharIndex() - 1, this._tokenStartLine,
    this._tokenStartColumn );
  this.emitToken( t );
}

AbstractAsciidocLexer.prototype.emitToken = function( t ) {
  let proto = Object.getPrototypeOf( this );
  //console.log(`${t.type} ${t.text.trim()}`);
  switch ( t.type ) {
    case proto.BLOCK_SECTION_TITLE:
      if ( this.isFirstSection )
        this.isFirstSection = false;
      else
        this.emitType( proto.SECTION_END, "<SECTION_END>" );
      break;
    default:
      break;
  }
  this.tokenQueue.push( t );
  this.isBOL = t.text.endsWith( "\n" );
}

AbstractAsciidocLexer.prototype.actualNextToken = function() {
  let t = this.tokenQueue.shift();
  if ( t )
    this.isBOL = t.text.endsWith( "\n" );
  return t;
}

AbstractAsciidocLexer.prototype.nextToken = function() {
  let t = this.actualNextToken();

  if ( !t ) {
    Object.getPrototypeOf( AbstractAsciidocLexer.prototype ).nextToken.call( this );
    t = this.actualNextToken();
  }

  return t;
}

module.exports = {
  AbstractAsciidocLexer: AbstractAsciidocLexer
}
