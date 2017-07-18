lexer grammar AsciidocLexer;

@lexer::members {

  public boolean isBOL() {
    return _input.LA(-1) == '\n';
  }

}

///////////////////
// default mode = header?

H0  
  : {isBOL()}?  
      '=' WS              -> pushMode(DOCTITLE)
  ;


fragment
SEC_TITLE_START_F
  : { isBOL() }? 
    ( '==' | '######' 
    | '===' | '#####'
    | '====' | '####'
    | '=====' | '###'
    | '======' | '##' ) 
  ;

ATTR_BEGIN
  : { isBOL() }?  ':'             -> pushMode(ATTR)
  ;

COMMENT
  : COMMENT_F                     -> channel(HIDDEN) 
  ;

fragment
COMMENT_F
  : '//' ~[\r\n]*                 
  ;

END_OF_HEADER
  : { isBOL() }? EOLF+            -> pushMode(CONTENT)
  ;

EOL
  : EOLF                -> channel(HIDDEN)
  ;

WS 
  : WS_CHAR+            -> channel(HIDDEN) 
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

fragment
WS_CHAR
  : [ \t]
  ;

fragment
ATTR_ID_F
  : [_a-zA-Z0-9] [-_a-zA-Z0-9]*
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
  : ATTR_ID_F
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


CONTENT_SEC_TITLE_START  
  : SEC_TITLE_START_F             -> mode(SECTION_TITLE)
  ;

CONTENT_ATTR_START
  : {isBOL()}? 
     '['                         -> pushMode(ELEMENT_ATTR)
  ;

CONTENT_PARA                     
  : {isBOL()}? 
      ~[=[] .*? CONTENT_EOP 
  ;


CONTENT_COMMENT
  : COMMENT_F                     -> channel(HIDDEN) 
  ;

CONTENT_EOP
  : EOLF EOLF+                    //-> popMode
  ;

///////////////////
mode ELEMENT_ATTR;


ELEMENT_ATTR_ID
  : ATTR_ID_F
  ;

ELEMENT_ATTR_COMMA
  :  ','
  ;

ELEMENT_ATTR_ASSIGN
  :  '='
  ;

ELEMENT_ATTR_END
  :  ']'                        
  ;

ELEMENT_ATTR_EOL
  :  EOLF                        -> popMode
  ;

ELEMENT_ATTR_VALUE
  : ~[\],=]+
  ;


