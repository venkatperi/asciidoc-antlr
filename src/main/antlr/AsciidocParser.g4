parser grammar AsciidocParser;

options { tokenVocab = AsciidocLexer; }


asciidoc
  : EOL* doc_header doc_sections EOF
  ;


doc_header
  : global_attrs? doc_title_line doc_author_line global_attrs? END_OF_HEADER
  ;

doc_title_line
  : H0 doc_title
  ;

doc_title
  : DOCTITLE_PART DOCTITLE_EOL 
  | DOCTITLE_PART (DOCTITLE_CSP DOCTITLE_PART)* (DOCTITLE_CSP doc_subtitle) DOCTITLE_EOL 
  ;

doc_subtitle
  : DOCTITLE_PART
  ;

///////////////////////
//author line

doc_author_line
  : doc_author (DOCAUTHOR_SEP doc_author)* DOCAUTHOR_EOL
  ;

doc_author
  : doc_author_name doc_author_contact 
  ;
  
doc_author_name
  : doc_author_firstname doc_author_middlename? doc_author_lastname
  ;

doc_author_firstname
  : DOCAUTHOR_NAME
  ;

doc_author_middlename
  : DOCAUTHOR_NAME
  ;

doc_author_lastname
  : DOCAUTHOR_NAME
  ;

doc_author_contact
  : DOCAUTHOR_CONTACT
  ;

///////////////////////
// global_attrs

global_attrs
  : global_attrs global_attr
  | global_attr
  ;

global_attr
  : ATTR_BEGIN attr_id_def attr_value ATTR_EOL
  ;

attr_id_def
  : attr_unset attr_id
  | attr_id attr_unset
  | attr_id
  ;

attr_id
  : ATTR_ID
  ;

attr_unset
  : ATTR_UNSET
  ;

attr_value
  : ATTR_VALUE
  ;

///////////////////////
// doc preamble


///////////////////////
// doc sections

doc_sections
  : doc_sections doc_section
  | doc_section
  ;

doc_section
  : element_attr_lines? 
      (CONTENT_SEC_TITLE_START) 
      section_title 
      sec_content_items
  ;

section_title
  :  SECTITLE_TEXT SECTITLE_EOL
  ;


///////////////////////
// element attributes

element_attr_lines
  : element_attr_lines element_attr_line
  | element_attr_line
  ;

element_attr_line
  :  CONTENT_ATTR_START  element_attrs ELEMENT_ATTR_END ELEMENT_ATTR_EOL
  ;

element_attrs
  : element_attrs ELEMENT_ATTR_COMMA element_attr
  | element_attr
  ;

element_attr
  : element_attr_id (ELEMENT_ATTR_ASSIGN element_attr_value)?
  ;

element_attr_id
  : ELEMENT_ATTR_ID
  ;

element_attr_value
  : ELEMENT_ATTR_VALUE
  ;


///////////////////////
// section content 

sec_content_items
  : sec_content_items sec_content_item 
  | sec_content_item
  ;

sec_content_item
  : paragraph 
  ;

paragraph
  : CONTENT_PARA
  ;
  
