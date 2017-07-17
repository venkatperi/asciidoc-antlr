lexer grammar AsciidocLexer;


///////////////////
// default mode

H0  
  : {getCharPositionInLine()==0}? 
    '=' WS              -> pushMode(DOCTITLE)
  ;

SEC_TITLE_START  
  : {getCharPositionInLine()==0}? 
    ( '==' | '######' 
    | '===' | '#####'
    | '====' | '####'
    | '=====' | '###'
    | '======' | '##' ) WS       -> pushMode(SECTION_TITLE)
  ;

ATTR_BEGIN
  : {getCharPositionInLine()==0}? 
      ':'             -> pushMode(ATTR)
  ;

COMMENT  
  : '//' ~[\r\n]*     -> channel(HIDDEN) 
  ;

WS 
  : [ \t]+            -> channel(HIDDEN) 
  ;

EOL 
  : EOLF 
  ;

fragment
BOL 
  : [\r\n\f]+     
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
COLON
  : ':'               
  ;

fragment
BANG
  : '!'               
  ;


///////////////////
mode DOCTITLE;

DOCTITLE_CSP
  : ': '              
  ;

DOCTITLE_PART
  : ((':' + ~' ') | ~[:\r\n])+
  ;

DOCTITLE_EOL
  : EOLF              -> mode(DOCAUTHOR)
  ;


///////////////////
mode DOCAUTHOR;

// extend for unicode, special chars etc. 
DOCAUTHOR_NAME
  : [-_a-zA-Z]+
  ;

// doesn't parse email/url
DOCAUTHOR_CONTACT
  : LT .*? GT 
  ;

DOCAUTHOR_SEP
  : SEMI               
  ;

DOCAUTHOR_EOL
  : EOLF              -> popMode
  ;

DOCAUTHOR_WS 
  : WS                -> channel(HIDDEN) 
  ;


///////////////////
mode ATTR;

ATTR_ID
  : [_a-zA-Z0-9] [-_a-zA-Z0-9]*
  ;

ATTR_VALUE
  : ':' ~[\r\n]*      
  ;

ATTR_UNSET
  : BANG 
  ;

ATTR_EOL
  : EOLF            -> popMode
  ;


///////////////////
mode SECTION_TITLE;

SECTITLE_TEXT
  : ~[\r\n]+
  ;

SECTITLE_EOL
  : EOLF+            -> mode(CONTENT)
  ;


///////////////////
mode CONTENT;


CONTENT_PARA
  : {getCharPositionInLine()==0}? 
    .*? CONTENT_EOP
  ;

CONTENT_EOP
  : EOLF EOLF+        -> popMode
  ;


