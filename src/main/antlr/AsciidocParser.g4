parser grammar AsciidocParser;

@members {
  private int sectionLevel = 0;
}

options { tokenVocab = AsciidocLexer; }

///////////////////////
// start rule

asciidoc
  : header section* EOF
  ;

///////////////////////
// doc header

header
  : (header_line | EOL)* doc_title_line author_rev? header_line* END_OF_HEADER
  ;

// You cannot have a revision line without an author line.
author_rev
  : authors revision?
  ;

header_line
  : global_attr
  | pp_directive
  ;

///////////////////////
// doc title

doc_title_line
  : H0 doc_title_def
  ;

doc_title_def
  : doc_title (DOCTITLE_CSP doc_subtitle)? DOCTITLE_EOL 
  ;

doc_title
  : DOCTITLE_PART (DOCTITLE_CSP DOCTITLE_PART)*? 
  ;

doc_subtitle
  : DOCTITLE_PART
  ;

///////////////////////
// doc author 

authors
  : author (AUTHOR_SEP author)* AUTHOR_EOL
  ;

author
  : author_firstname author_middlename? author_lastname 
    author_contact 
  ;
  
author_firstname
  : AUTHOR_NAME
  ;

author_middlename
  : AUTHOR_NAME
  ;

author_lastname
  : AUTHOR_NAME
  ;

author_contact
  : AUTHOR_CONTACT
  ;

///////////////////////
// doc revision

revision
  : (REV_NUMPREFIX? rev_number REV_COMMA)? 
    rev_date?
    (REV_COLON rev_remark)? REV_EOL
  ;

rev_number
  : REV_NUMBER
  ;

rev_date
  : REV_DATE
  ;

rev_remark
  : REV_REMARK
  ;

///////////////////////
// global_attrs

global_attr
  : ATTR_BEGIN attr_def ATTR_EOL
  ;

attr_def
  : attr_unset ATTR_SEP
  | attr_set
  ;

attr_set
  : attr_id ATTR_SEP attr_value?
  ;

attr_unset
  : ATTR_UNSET attr_id
  | attr_id ATTR_UNSET
  ;

attr_id
  : ATTR_ID
  ;

attr_value
  : ATTR_VALUE
  ;

///////////////////////
// doc preamble


///////////////////////
// doc sections

section
  : section_header section_body ( SECTION_END | EOF )
  ;

section_header
  : block_attr_line* SECTITLE_START section_title SECTITLE_EOL  
  ;

section_title
  :  SECTITLE_TEXT 
  ;

///////////////////////
// element attributes

block_attr_line
  :  BLOCK_ATTR_START  block_attr (BLOCK_ATTR_COMMA block_attr)* BLOCK_ATTR_END BLOCK_ATTR_EOL
  ;

block_attr
  : block_named_attr
  | block_positional_attr
  ;

block_positional_attr
  : block_pos_prefixed_attr*
  | block_attr_id     //style etc 
  ;

block_pos_prefixed_attr
  : block_pos_attr_role
  | block_pos_attr_id
  | block_pos_attr_id
  ;

block_pos_attr_role
  : BLOCK_ATTR_TYPE_ROLE block_attr_id
  ;

block_pos_attr_id
  : BLOCK_ATTR_TYPE_ID block_attr_id
  ;

block_pos_attr_option
  : BLOCK_ATTR_TYPE_OPTION block_attr_id
  ;

block_named_attr
  : block_attr_id BLOCK_ATTR_ASSIGN block_attr_value
  ;

block_attr_id
  : BLOCK_ATTR_ID
  ;

block_attr_value
  : BLOCK_ATTR_VALUE
  ;


///////////////////////
// section content 

section_body
  : section_body_item*
  ;

section_body_item
  : block_attr_line* block_title_line?
    ( paragraph
    | delim_block
    )
  ;

paragraph
  : BLOCK_PARA
  ;
  
///////////////////////
// block/element title mode 

block_title_line
  : BLOCK_TITLE_START block_title
  ;

block_title
  : BLOCK_TITLE_TEXT BLOCK_TITLE_EOL
  ;
  
  
///////////////////////
// delimited blocks 

delim_block
  : (sidebar_block
    | comment_block
    | fenced_block
    | example_block
    | listing_block
    | literal_block
    | pass_block
    | verse_block
    | table_block
    | anon_block
    )
  ;

table_block
  :  BLOCK_TABLE_START delim_block_content DELIM_BLOCK_END
  ;

comment_block
  :  BLOCK_COMMENT_START delim_block_content DELIM_BLOCK_END
  ;

fenced_block
  :  BLOCK_FENCED_START delim_block_content DELIM_BLOCK_END
  ;

example_block
  :  BLOCK_EXAMPLE_START delim_block_content DELIM_BLOCK_END
  ;

listing_block
  :  BLOCK_LISTING_START delim_block_content DELIM_BLOCK_END
  ;

literal_block
  :  BLOCK_LITERAL_START delim_block_content DELIM_BLOCK_END
  ;

pass_block
  :  BLOCK_PASS_START delim_block_content DELIM_BLOCK_END
  ;

verse_block
  :  BLOCK_VERSE_START delim_block_content DELIM_BLOCK_END
  ;

sidebar_block
  :  BLOCK_SIDEBAR_START delim_block_content DELIM_BLOCK_END
  ;

anon_block
  :  BLOCK_ANON_START delim_block_content DELIM_BLOCK_END
  ;

delim_block_content
  : DELIM_BLOCK_LINE*
  ;

///////////////////////
// conditional pre-processor directives

pp_directive
  : PPD_START ppd_attr (PPD_ATTR_SEP ppd_attr)* ppd_content
  ;

ppd_attr
  : PPD_ATTR_ID
  ;

ppd_content
  : PPD_CONTENT_SINGLELINE
  | PPD_CONTENT_START PPD_CONTENT
  ;

