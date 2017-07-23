lexer grammar AsciidocLexer;

options {
  superClass=AbstractAsciidocLexer;
}

tokens {
  SECTION_END
}


///////////////////
// default mode 

H0  
  : {this.isBOL}?  
      EQUAL WS                    -> pushMode(DOCTITLE)
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

END_OF_HEADER
  : { this.isBOL }? 
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
  : WS_CHAR* EOLF                        -> popMode
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
    if (this.isFirstSection) 
      this.isFirstSection = false;
    else
      this.emitType(this.SECTION_END);	
    
    this.mode(this.SECTION_TITLE);
  }
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
// delimited blocks


BLOCK_TABLE_START
  : {this.isBOL}? 
    '|===' WS_CHAR* EOLF
    { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
  ;

BLOCK_ANON_START
  : {this.isBOL}? 
    '--' WS_CHAR* EOLF
    { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
  ;

BLOCK_COMMENT_START
  : {this.isBOL}? 
    ( '////' 
    | '/////'
    | '//////'
    | '///////'
    | '////////'
    | '/////////'
    | '//////////'
    )
    WS_CHAR* EOLF
    { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
  ;

BLOCK_EXAMPLE_START
  : {this.isBOL}? 
    ( '====' 
    | '====='
    | '======'
    | '======='
    | '========'
    | '========='
    | '=========='
    )
    WS_CHAR* EOLF
    { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
  ;

BLOCK_FENCED_START
  : {this.isBOL}? '```' 
    (WS_CHAR* | LETTER*) EOLF         
    { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
  ;

BLOCK_LISTING_START
  : {this.isBOL}? 
    ( '----' 
    | '-----'
    | '------'
    | '-------'
    | '--------'
    | '---------'
    | '----------'
    )
    WS_CHAR* EOLF         
    { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
  ;

BLOCK_LITERAL_START
  : {this.isBOL}? 
    ( '....' 
    | '.....'
    | '......'
    | '.......'
    | '........'
    | '.........'
    | '..........'
    )
    WS_CHAR* EOLF
    { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
  ;

BLOCK_PASS_START
  : {this.isBOL}? 
    ( '++++' 
    | '+++++'
    | '++++++'
    | '+++++++'
    | '++++++++'
    | '+++++++++'
    | '++++++++++'
    )
    WS_CHAR* EOLF         
    { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
  ;

BLOCK_SIDEBAR_START
  : {this.isBOL}? 
    ( '****' 
    | '*****'
    | '******'
    | '*******'
    | '********'
    | '*********'
    | '**********'
    ) 
    WS_CHAR* EOLF          
  { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
  ;

BLOCK_VERSE_START
  : {this.isBOL}? 
    ( '____' 
    | '_____'
    | '______'
    | '_______'
    | '________'
    | '_________'
    | '__________'
    )
    WS_CHAR* EOLF
    { this.startDelimBlock(); this.pushMode(this.DELIM_CONTENT); }
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
    ~[\r\n]*   
    EOLF
    {!this.isDelimBlockEnd()}?
  ;

DELIM_BLOCK_END           
  : {this.isBOL}? 
    ~[\r\n]+   
    EOLF+
    {this.isDelimBlockEnd()}?                   -> popMode
  ;


