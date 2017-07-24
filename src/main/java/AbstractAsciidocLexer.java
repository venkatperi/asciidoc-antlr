import java.util.ArrayDeque;

import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

abstract class AbstractAsciidocLexer extends Lexer {
  public static int MIN_DELIM_LENGTH = 4;

  private ArrayDeque<Token> tokenQueue = new ArrayDeque<Token>();

  public String delimBlockBoundary = null;
  public boolean isFirstSection = true;
  public boolean isBOL = false;

  public AbstractAsciidocLexer(CharStream input) {
    super(input);
  }

  public int getDelimBoundaryType(String str) {
    switch (str) {
    case "|===":
      return AsciidocLexer.BLOCK_TABLE_START;

    case "--":
      return AsciidocLexer.BLOCK_ANON_START;

    case "```":
      return AsciidocLexer.BLOCK_FENCED_START;

    case "////":
      return AsciidocLexer.BLOCK_COMMENT_START;

    case "====":
      return AsciidocLexer.BLOCK_EXAMPLE_START;

    case "----":
      return AsciidocLexer.BLOCK_LISTING_START;

    case "....":
      return AsciidocLexer.BLOCK_LITERAL_START;

    case "++++":
      return AsciidocLexer.BLOCK_PASS_START;

    case "****":
      return AsciidocLexer.BLOCK_SIDEBAR_START;

    case "____":
      return AsciidocLexer.BLOCK_VERSE_START;
    }

    return -1;
  }

  public boolean isDelimBlockStart() {
    String text = getText().trim();
    if (text.length() == 0) return false;

    char ch = text.charAt(0);
    int len = text.length();
    boolean repeating = false;
    if (len >= MIN_DELIM_LENGTH) {
      repeating = true;
      for (int i = 1; i < len; i++) {
        if (ch != text.charAt(i)) {
          repeating = false;
          break;
        }
      }
    }

    String str = repeating ?  text.substring(0, MIN_DELIM_LENGTH) : text;
    return getDelimBoundaryType(str) > 0;
  }


  public void startDelimBlock() {
    String text = getText().trim();
    if (text.startsWith("```"))
      text = "```";
    delimBlockBoundary = text;
    String s = text.length() > MIN_DELIM_LENGTH ? text.substring(0, MIN_DELIM_LENGTH) : text;
    setType(getDelimBoundaryType(s));
    pushMode(AsciidocLexer.DELIM_CONTENT);
  }

  public boolean isDelimBlockEnd() {
    return getText().trim().equals(delimBlockBoundary);
  }

  public void emitType(int type) {
    emitType(type, null);
  }

  public void emitType(int type, String text) {
    Token t = _factory.create(_tokenFactorySourcePair, type, text, _channel,
                              _tokenStartCharIndex, getCharIndex() - 1, _tokenStartLine,
                              _tokenStartCharPositionInLine);
    emit(t);
  }

  @Override public void emit(Token t) {
    switch (t.getType() ) {
    case AsciidocLexer.BLOCK_SECTION_TITLE:
      if (isFirstSection)
        isFirstSection = false;
      else
        emitType(AsciidocLexer.SECTION_END, "<SECTION_END>");
      break;
    default:
      break;
    }
    tokenQueue.add(t);
    isBOL = t.getText().endsWith("\n");
  }

  public Token actualNextToken() {
    Token t = tokenQueue.poll();
    //if (t != null) System.out.println("next: " + t.getType() + ", " + t.getText().trim());
    return t;
  }

  @Override
  public Token nextToken() {
    //System.out.println("nextToken()");
    Token t = actualNextToken();
    if (t == null) {
      super.nextToken();
      t = actualNextToken();
    }
    return t;
  }

}
