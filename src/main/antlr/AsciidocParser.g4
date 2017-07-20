parser grammar AsciidocParser;

@members {
  private int sectionLevel = 0;
}

options { tokenVocab = AsciidocLexer; }

///////////////////////
// start rule

asciidoc
  : pre_header_lines? header sections EOF
  ;

pre_header_lines
  : pre_header_lines pre_header_line
  | pre_header_line
  ;

pre_header_line
  : global_attr
  | pp_directive
  | EOL
  ;

///////////////////////
// doc header

header
  : doc_title_line author_rev_line? header_lines? END_OF_HEADER
  ;

// You cannot have a revision line without an author line.
author_rev_line
  : author_line revision_line?
  ;

header_lines
  : header_lines header_line
  | header_line
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

author_line
  : authors AUTHOR_EOL
  ;

authors
  : authors AUTHOR_SEP author
  | author
  ;

author
  : author_name 
    author_contact 
  ;
  
author_name
  : author_firstname 
    author_middlename? 
    author_lastname
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

revision_line
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

global_attrs
  : global_attrs global_attr
  | global_attr
  ;

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

sections
  : sections section
  | section
  ;

section
  : section_start_lines sec_body_items (SECTION_END | EOF)
  ;

section_start_lines
  : block_attr_lines? section_title_line 
  ;

section_title_line
  : SECTITLE_START section_title SECTITLE_EOL  
  ;

section_title
  :  SECTITLE_TEXT 
  ;

///////////////////////
// element attributes

block_attr_lines
  : block_attr_lines block_attr_line
  | block_attr_line
  ;

block_attr_line
  :  BLOCK_ATTR_START  block_attrs BLOCK_ATTR_END BLOCK_ATTR_EOL
  ;

block_attrs
  : block_attrs BLOCK_ATTR_COMMA block_attr
  | block_attr
  ;

block_attr
  : block_named_attr
  | block_positional_attr
  ;

block_positional_attr
  : block_pos_prefixed_attrs
  | block_attr_id     //style etc 
  ;

block_pos_prefixed_attrs
  : block_pos_prefixed_attrs block_pos_prefixed_attr
  | block_pos_prefixed_attr
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

sec_body_items
  : sec_body_items sec_body_item 
  | sec_body_item
  ;

sec_body_item
  : body_item_metas? body_item
  ;

body_item_metas  
  : body_item_metas body_item_meta
  | body_item_meta
  ;

body_item_meta
  : block_attr_line
  | block_title_line
  ;

body_item
  : paragraph
  | section
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
// conditional pre-processor directives

pp_directive
  : PPD_START ppd_attrs ppd_content
  ;

ppd_attrs
  : ppd_attrs PPD_ATTR_SEP ppd_attr
  | ppd_attr
  ;

ppd_attr
  : PPD_ATTR_ID
  ;

ppd_content
  : PPD_CONTENT_SINGLELINE
  | PPD_CONTENT_START PPD_CONTENT
  ;

