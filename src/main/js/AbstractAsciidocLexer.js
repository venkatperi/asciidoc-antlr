const antlr4 = require( 'antlr4' );

function AbstractAsciidocLexer( input ) {
  antlr4.Lexer.call( this, input );
  return this;
}

AbstractAsciidocLexer.prototype = Object.create( antlr4.Lexer.prototype );

AbstractAsciidocLexer.prototype.isFirstSection = true;

AbstractAsciidocLexer.prototype.tokenQueue = [];

AbstractAsciidocLexer.prototype.startDelimBlock = function() {
  let s = this.text.trim();
  this.delimBlockBoundary = s;
  if ( s.startsWith( "```" ) )
    this.delimBlockBoundary = "```";
}

AbstractAsciidocLexer.prototype.isDelimBlockEnd = function() {
  return this.text.trim() === this.delimBlockBoundary;
}

AbstractAsciidocLexer.prototype.emitType = function( type ) {
  var t = this._factory.create( this._tokenFactorySourcePair, type,
    this._text, this._channel, this._tokenStartCharIndex, this
    .getCharIndex() - 1, this._tokenStartLine,
    this._tokenStartColumn );
  this.emitToken( t );
}

AbstractAsciidocLexer.prototype.emitToken = function( t ) {
  //console.log('emitToken: ' + t.text);
  this.tokenQueue.push( t );
  this.isBOL = t.text.endsWith( "\n" );
}

AbstractAsciidocLexer.prototype.nextToken = function() {
  if ( this.tokenQueue.length > 0 ) {
    return this.tokenQueue.shift();
  }

  Object.getPrototypeOf( AbstractAsciidocLexer.prototype ).nextToken.call( this );

  if ( this.tokenQueue.length ) {
    return this.tokenQueue.shift();
  }

  return null;
}

module.exports = {
  AbstractAsciidocLexer: AbstractAsciidocLexer
}
