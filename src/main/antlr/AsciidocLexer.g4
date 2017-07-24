lexer grammar AsciidocLexer;

options {
  superClass=AbstractAsciidocLexer;
}

tokens {
  SECTION_END,
  BLOCK_TABLE_START,
  BLOCK_ANON_START,
  BLOCK_COMMENT_START,
  BLOCK_FENCED_START,
  BLOCK_LISTING_START,
  BLOCK_LITERAL_START,
  BLOCK_PASS_START,
  BLOCK_SIDEBAR_START,
  BLOCK_VERSE_START,
  BLOCK_EXAMPLE_START
}


///////////////////
// default mode 

H0  
  : {this.isBOL}?  
      EQUAL WS ~[\r\n]+ EOLF		  -> pushMode(HEADER)
  ;

ATTR_BEGIN
  : { this.isBOL }?  
      COLON                       -> pushMode(ATTR)
  ;

PPD_START
  : { this.isBOL }? 
      ( 'ifdef' 
      | 'ifndef' 
      | 'ifeval' ) '::' WS_CHAR*  -> pushMode(PPMODE)
  ;

COMMENT
  : COMMENT_F                     -> channel(HIDDEN) 
  ;

EOL
  : EOLF                          -> channel(HIDDEN)
  ;

WS 
  : WS_CHAR+                      -> channel(HIDDEN) 
  ;

fragment
COMMENT_F
  : '//' ~'/' ~[\r\n]*?  EOLF+          
  ;

fragment
SEC_TITLE_START_F
  : { this.isBOL }? 
      ( '==' | '######' 
      | '===' | '#####'
      | '====' | '####'
      | '=====' | '###'
      | '======' | '##' ) WS_CHAR+
    ;

fragment
EOLF
  : '\r'? '\n'
  ;

fragment
LETTER 
  : [\p{L}]
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
  : [\p{N}]
  ; 

fragment 
PUNCT 
  : [\p{P}]
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
  : EOLF                            -> mode(HEADER) 
  ;

///////////////////
mode HEADER;

AUTHOR
  : AUTHOR_NAME AUTHOR_NAME? AUTHOR_NAME AUTHOR_CONTACT (SEMI WS_CHAR* AUTHOR)* EOLF
	;

// any non-whitespace char 
fragment
AUTHOR_NAME
  : ~[ <>;\r\n]+ WS_CHAR+
  ;

fragment
AUTHOR_CONTACT
  : LT .*? GT  WS_CHAR*
  ;

fragment
HEADER_EOL
  : EOLF                          //-> mode(REV)
  ;

END_OF_HEADER
  : { this.isBOL }? 
      WS_CHAR* EOLF+              -> mode(BLOCK)
  ;

REVISION
  : { this.isBOL }?
		( ( ( ([vV] REV_NUMBER ) | (REV_NUMBER COMMA )) REV_REMARK_F? )
		| ( [vV]? REV_NUMBER COMMA REV_DATE REV_REMARK_F? )
		| ( ([vV] REV_NUMBER ) | (REV_NUMBER COMMA ))
		) EOLF
  ;

fragment
REV_NUMPREFIX
  : [vV] 
  ;

fragment
REV_DATE
  : WS_CHAR* ~[:\r\n]+ WS_CHAR* 
  ;

fragment
REV_REMARK_F
  : COLON WS_CHAR* ~[\r\n]+
	;

fragment
REV_NUMBER
  : DIGIT+ (PERIOD DIGIT+)*
  ;

fragment
REV_COMMA
  : COMMA WS_CHAR*                //-> mode(REV_DATE_MODE)
  ;

fragment
REV_COLON
  : COLON WS_CHAR*                //-> mode(REV_REM)
  ;

fragment
REV_EOL
  : EOLF                          //-> popMode
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
  : WS_CHAR* EOLF                        -> popMode
  ;

///////////////////
mode BLOCK;

BLOCK_SECTION_TITLE  
  : SEC_TITLE_START_F  ~[\r\n]+ EOLF+             
  ;

BLOCK_ANCHOR
  : {this.isBOL}? 
    '[[' .*? ']]'  EOLF+
  ;

BLOCK_ATTR_START
  : {this.isBOL}? 
     '[' WS_CHAR*                   -> pushMode(BLOCK_ATTR)
  ;

BLOCK_TITLE_START
  : {this.isBOL}? 
     '.'                            -> pushMode(BLOCK_TITLE_MODE)
  ;

BLOCK_DELIM_START
  : {this.isBOL}?
    ~[\r\n]+ EOLF
    {this.isDelimBlockStart()}?
    {this.startDelimBlock();}
  ;

BLOCK_PARA                     
  : {this.isBOL}? 
      ( ( [/|+*`\-_=] (LETTER | DIGIT | WS_CHAR) ) 
      |  ~[/|+*`\-_=[.]
      )
      .*? BLOCK_EOP 
  ;

BLOCK_COMMENT
  : COMMENT_F                       -> channel(HIDDEN) 
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
  : .*? EOLF 'endif::[]' EOLF+                    -> popMode
  ;

///////////////////
mode DELIM_CONTENT;

DELIM_BLOCK_LINE
  : {this.isBOL}?
    ~[\r\n]* EOLF
    {!this.isDelimBlockEnd()}?
  ;

DELIM_BLOCK_END           
  : {this.isBOL}? 
    ~[\r\n]+ EOLF+
    {this.isDelimBlockEnd()}?                   -> popMode
  ;


