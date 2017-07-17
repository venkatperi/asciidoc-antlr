lexer grammar AsciidocLexer;


///////////////////
// default mode

H0  
  : {getCharPositionInLine()==0}? 
    '=' WS              -> pushMode(DOCTITLE)
  ;

H1  
  : {getCharPositionInLine()==0}? 
    '==' WS             -> pushMode(SECTION_TITLE)
  ;

H2  
  : BOL '===' WS        -> pushMode(SECTION_TITLE)
  ;

H3  
  : BOL '====' WS        -> pushMode(SECTION_TITLE)
  ;

H4  
  : BOL '=====' WS        -> pushMode(SECTION_TITLE)
  ;

H5  
  : BOL '======' WS        -> pushMode(SECTION_TITLE)
  ;

ATTR_BEGIN
  : {getCharPositionInLine()==0}? 
      ':'             -> pushMode(ATTR)
  ;


COMMENT  
  : '//' ~[\r\n]*     -> channel(HIDDEN) 
  ;

SEMI
  : ';'
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

///////////////////
mode DOCTITLE;

DOCTITLE_CSP
  : ': '              //-> mode(DOCSUBTITLE)
  ;

DOCTITLE_PART
  : ((':' + ~' ') | ~[:\r\n])+
  ;

DOCTITLE_EOL
  : '\r'? '\n'        -> mode(DOCAUTHOR)
  ;


///////////////////
mode DOCAUTHOR;

DOCAUTHOR_NAME
  : [-_a-zA-Z]+
  ;

DOCAUTHOR_CONTACT
  : DOCAUTHOR_LT .*? DOCAUTHOR_GT
  ;

DOCAUTHOR_GT
  : '>'               
  ;

DOCAUTHOR_LT
  : '<'                
  ;

DOCAUTHOR_SEP
  : ';'               
  ;

DOCAUTHOR_EOL
  : '\r'? '\n'        -> popMode
  ;

DOCAUTHOR_WS 
  : [ \t]+            -> channel(HIDDEN) 
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
  : '!'
  ;

ATTR_EOL
  : '\r'? '\n'        -> popMode
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
  //: {getCharPositionInLine()==0 && (_input.LA(1)=='\r'  || _input.LA(1)=='\n')}? 
  : {getCharPositionInLine()==0}? 
    .*? CONTENT_EOP
  ;

fragment
CONTENT_EOP
  : EOLF EOLF+        
  ;


