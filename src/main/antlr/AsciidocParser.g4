parser grammar AsciidocParser;

options { tokenVocab = AsciidocLexer; }


asciidoc
  : EOL* doc_header doc_sections EOF
  ;


doc_header
  : attributes? doc_title_line doc_author_line attributes? EOL+
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
// attributes

attributes
  : attributes attribute
  | attribute
  ;

attribute
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
  : l1_sections
  ;

l1_sections
  : l1_sections l1_section
  | l1_section
  ;

l1_section
  : H1 section_title l1_content_items
  ;

section_title
  :  SECTITLE_TEXT SECTITLE_EOL
  ;


///////////////////////
// content 

l1_content_items
  : l1_content_items l1_content_item 
  | l1_content_item
  ;

l1_content_item
  : paragraph 
  ;

paragraph
  : CONTENT_PARA
  ;
  
