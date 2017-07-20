lexer grammar AsciidocLexer;

tokens {
  SECTION_END
}

@header {
  import java.util.ArrayDeque;
}

@lexer::members {

  private ArrayDeque<Token> tokenQueue = new ArrayDeque<Token>();
  private int currentSectionLevel = 0;
  public boolean isBOL() { return _input.LA(-1) == '\n'; }

	public void emit(int type) {
		Token t = _factory.create(_tokenFactorySourcePair, type, null, _channel, 
								_tokenStartCharIndex, getCharIndex()-1, _tokenStartLine, 
								_tokenStartCharPositionInLine);
		emit(t);
	}

  @Override public void emit(Token t) {
    tokenQueue.add(t);
  }

	@Override
	public Token nextToken() {
		if (tokenQueue.peek() != null) {
			return tokenQueue.remove();
		}

		super.nextToken();

		if (tokenQueue.peek() != null) {
			return tokenQueue.remove();
		}
		return null;
	}

}

///////////////////
// default mode 

H0  
  : {isBOL()}?  
      EQUAL WS                    -> pushMode(DOCTITLE)
  ;

ATTR_BEGIN
  : { isBOL() }?  
      COLON                       -> pushMode(ATTR)
  ;

PPD_START
  : { isBOL() }? 
      ( 'ifdef' 
      | 'ifndef' 
      | 'ifeval' ) '::' WS_CHAR*  -> pushMode(PPMODE)
  ;

COMMENT
  : COMMENT_F                     -> channel(HIDDEN) 
  ;

END_OF_HEADER
  : { isBOL() }? 
      EOLF+                       -> pushMode(BLOCK)
  ;

EOL
  : EOLF                          -> channel(HIDDEN)
  ;

WS 
  : WS_CHAR+                      -> channel(HIDDEN) 
  ;

fragment
COMMENT_F
  : '//' ~[\r\n]*                 
  ;

fragment
SEC_TITLE_START_F
  : { isBOL() }? 
      ( '==' | '######' 
      | '===' | '#####'
      | '====' | '####'
      | '=====' | '###'
      | '======' | '##' ) WS_CHAR+
    ;

fragment
H1
  : '=='  
  ;

fragment
H2
  : '==='  
  ;

fragment
H3
  : '===='  
  ;

fragment
H4
  : '====='  
  ;

fragment
H5
  : '======'  
  ;


fragment
EOLF
  : '\r'? '\n'
  ;

fragment
GT
  : '>'               
  ;

fragment
LT
  : '<'                
  ;

fragment
SEMI
  : ';'               
  ;

fragment
ESC
  : '\\'               
  ;

fragment
SINGLE_QUOTE
  : '\''               
  ;

fragment
DOUBLE_QUOTE
  : '"'               
  ;

fragment
COMMA
  : ','               
  ;

fragment
EQUAL
  : '='               
  ;

fragment
HASH
  : '#'               
  ;

fragment
PERCENT
  : '%'               
  ;

fragment
PERIOD
  : '.'               
  ;

fragment
COLON
  : ':'               
  ;

fragment
BANG
  : '!'               
  ;

fragment
WS_CHAR
  : [ \t]
  ;

fragment
SPACE
  : ' '
  ;

fragment 
DIGIT 
  : [0-9] 
  ; 

fragment
ATTR_ID_F
  : [_a-zA-Z0-9] [-_a-zA-Z0-9]*
  ;

///////////////////
mode DOCTITLE;

DOCTITLE_CSP
  : COLON SPACE 
  ;

DOCTITLE_PART
  : ((':' + ~' ') | ~[:\r\n])+
  ;

DOCTITLE_EOL
  : EOLF                            -> mode(AUTHOR)
  ;

///////////////////
mode AUTHOR;

// any non-whitespace char 
AUTHOR_NAME
  : ~[ <>;\r\n]+
  ;

AUTHOR_CONTACT
  : LT .*? GT 
  ;

AUTHOR_SEP
  : SEMI               
  ;

AUTHOR_EOL
  : EOLF                          -> mode(REV)
  ;

AUTHOR_WS 
  : WS                            -> channel(HIDDEN) 
  ;


///////////////////
mode REV;


REV_NUMPREFIX
  : [vV] 
  ;

REV_NUMBER
  : DIGIT+ (PERIOD DIGIT+)*
  ;

REV_COMMA
  : COMMA WS_CHAR*                -> mode(REV_DATE_MODE)
  ;

REV_COLON
  : COLON WS_CHAR*                -> mode(REV_REM)
  ;

REV_EOL
  : EOLF                          -> popMode
  ;

///////////////////
mode REV_DATE_MODE;

REV_DATE
  : ~[:\r\n]+
  ;

REV_DATE_COLON
  : COLON WS_CHAR*               -> type(REV_COLON), mode(REV_REM)
  ;

REV_DATE_EOL
  : EOLF                         -> type(REV_EOL), popMode
  ;

///////////////////
mode REV_REM;

REV_REMARK
  : ~[\r\n]+  
  ;

REV_REMARK_EOL
  : EOLF                          -> type(REV_EOL), popMode
  ;

///////////////////
mode ATTR;

ATTR_ID
  : ATTR_ID_F                       
  ;

ATTR_UNSET
  : BANG 
  ;

ATTR_SEP
  : COLON WS_CHAR*                  -> mode(ATTR_VALUE_MODE)
  ;


///////////////////
mode ATTR_VALUE_MODE;

ATTR_VALUE
  : (~[\\\r\n] | (ESC EOLF) )+      
  ;

ATTR_EOL
  : WS_CHAR* EOLF                            -> popMode
  ;

///////////////////
mode SECTION_TITLE;

SECTITLE_TEXT
  : ~[\r\n]+
  ;

SECTITLE_EOL
  : EOLF+                           -> mode(BLOCK)
  ;


///////////////////
mode BLOCK;

SECTITLE_START  
  : SEC_TITLE_START_F               
  {
    int level = getText().trim().length() - 1;
		if (level <= currentSectionLevel) {
			for (int i=0; i<=currentSectionLevel - level; i++)
				emit(SECTION_END);	
		}
		else if (level > currentSectionLevel + 1) {
			throw new RuntimeException("line " + getLine() + ":" + getCharPositionInLine() 
				+ " Illegal subsection header: found :" + level 
				+ ", required: " + (currentSectionLevel + 1));
		}
		currentSectionLevel = level;
    mode(SECTION_TITLE);
  }

  ;

BLOCK_ATTR_START
  : {isBOL()}? 
     '[' WS_CHAR*                   -> pushMode(BLOCK_ATTR)
  ;

BLOCK_TITLE_START
  : {isBOL()}? 
     '.'                            -> pushMode(BLOCK_TITLE_MODE)
  ;

BLOCK_PARA                     
  : {isBOL()}? 
      ~[=[.] .*? BLOCK_EOP 
  ;

BLOCK_COMMENT
  : COMMENT_F                     -> channel(HIDDEN) 
  ;

BLOCK_EOP
  : EOLF EOLF+                    
  ;


///////////////////
mode BLOCK_ATTR;

BLOCK_ATTR_ID
  : ATTR_ID_F
  ;

BLOCK_ATTR_COMMA
  :  WS_CHAR* COMMA WS_CHAR*
  ;

BLOCK_ATTR_ASSIGN
  :  WS_CHAR* EQUAL                        -> pushMode(BLOCK_ATTR_VAL)
  ;

BLOCK_ATTR_TYPE_ROLE
  :  WS_CHAR* PERIOD                        
  ;

BLOCK_ATTR_TYPE_OPTION
  :  WS_CHAR* PERCENT                        
  ;

BLOCK_ATTR_TYPE_ID
  :  WS_CHAR* HASH                       
  ;

BLOCK_ATTR_UNSET
  : WS_CHAR* BANG  
  ;

BLOCK_ATTR_END
  :  WS_CHAR* ']'                        
  ;

BLOCK_ATTR_EOL
  :  WS_CHAR* EOLF                        -> popMode
  ;

///////////////////
mode BLOCK_ATTR_VAL;

fragment 
BLOCK_ATTR_VALUE_QUOTED_SINGLE
  : SINGLE_QUOTE (~['\r\n] | (ESC SINGLE_QUOTE))*? SINGLE_QUOTE
  ;

fragment 
BLOCK_ATTR_VALUE_QUOTED_DOUBLE
  : DOUBLE_QUOTE (~["\r\n] | (ESC DOUBLE_QUOTE))*? DOUBLE_QUOTE
  ;

fragment 
BLOCK_ATTR_VALUE_UNQUOTED
  : ~['"\],\r\n ]*?
  ;

BLOCK_ATTR_VALUE
  : ( BLOCK_ATTR_VALUE_QUOTED_SINGLE                               
    | BLOCK_ATTR_VALUE_QUOTED_DOUBLE
    | BLOCK_ATTR_VALUE_UNQUOTED )           -> popMode
  ;

///////////////////
mode BLOCK_TITLE_MODE;

BLOCK_TITLE_TEXT
  : ~[\r\n]+                               
  ;

BLOCK_TITLE_EOL
  : EOLF                                  -> popMode
  ;


///////////////////
mode PPMODE;

PPD_ATTR_ID
  : ATTR_ID_F
  ;

PPD_ATTR_SEP
  : WS_CHAR* [+,] WS_CHAR*
  ;

PPD_CONTENT_SINGLELINE
  :  '[' ~[\]\r\n]+ ']' EOLF                     -> popMode
  ;

PPD_CONTENT_START
  :  '[]' EOLF                                   -> mode(PPCONTENT)
  ;

///////////////////
mode PPCONTENT;

PPD_CONTENT
  : .*? EOLF 'endif::[]' EOLF                    -> popMode
  ;


