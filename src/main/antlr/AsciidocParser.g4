parser grammar AsciidocParser;


options { tokenVocab = AsciidocLexer; }

///////////////////////
// start rule

asciidoc
  : pre_header_lines? doc_header doc_sections EOF
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

doc_header
  : doc_title_line doc_author_rev_line? doc_header_lines? END_OF_HEADER
  ;

// You cannot have a revision line without an author line.
doc_author_rev_line
  : doc_author_line doc_revision_line?
  ;

doc_header_lines
  : doc_header_lines doc_header_line
  | doc_header_line
  ;

doc_header_line
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

doc_author_line
  : doc_authors DOCAUTHOR_EOL
  ;

doc_authors
  : doc_authors DOCAUTHOR_SEP doc_author
  | doc_author
  ;

doc_author
  : doc_author_name 
    doc_author_contact 
  ;
  
doc_author_name
  : doc_author_firstname 
    doc_author_middlename? 
    doc_author_lastname
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
// doc revision

doc_revision_line
  : (DOCREV_NUMPREFIX? doc_rev_number DOCREV_COMMA)? 
    doc_rev_date?
    (DOCREV_COLON doc_rev_remark)? DOCREV_EOL
  ;

doc_rev_number
  : DOCREV_NUMBER
  ;

doc_rev_date
  : DOCREV_DATE
  ;

doc_rev_remark
  : DOCREV_REMARK
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

doc_sections
  : doc_sections doc_section
  | doc_section
  ;

doc_section
  : section_start_lines sec_content_items
  ;

section_start_lines
  : element_attr_lines? section_title_line 
  ;

section_title_line
  : CONTENT_SEC_TITLE_START section_title SECTITLE_EOL
  ;

section_title
  :  SECTITLE_TEXT 
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
  : element_named_attr
  | element_positional_attr
  ;

element_positional_attr
  : element_pos_prefixed_attrs
  | element_attr_id     //style etc 
  ;

element_pos_prefixed_attrs
  : element_pos_prefixed_attrs element_pos_prefixed_attr
  | element_pos_prefixed_attr
  ;

element_pos_prefixed_attr
  : element_pos_attr_role
  | element_pos_attr_id
  | element_pos_attr_id
  ;

element_pos_attr_role
  : ELEMENT_ATTR_TYPE_ROLE element_attr_id
  ;

element_pos_attr_id
  : ELEMENT_ATTR_TYPE_ID element_attr_id
  ;

element_pos_attr_option
  : ELEMENT_ATTR_TYPE_OPTION element_attr_id
  ;

element_named_attr
  : element_attr_id ELEMENT_ATTR_ASSIGN element_attr_value
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
  : sec_content_metas? paragraph 
  ;

sec_content_metas
  : sec_content_metas sec_content_meta
  | sec_content_meta
  ;

sec_content_meta
  : element_attr_line
  //| content_title_line
  ;

//content_title_line
  //: CONTENT_TITLE_START content_title_text CONTENT_TITLE_EOL
  //;

//content_title_text
  //: CONTENT_TITLE_TEXT
  //;

paragraph
  : CONTENT_PARA
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

