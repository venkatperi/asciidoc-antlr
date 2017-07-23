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
  private ArrayDeque<Token> tokenQueue = new ArrayDeque<Token>();

  public String delimBlockBoundary = null;
  public boolean isFirstSection = true;
  public boolean isBOL = false;

  public AbstractAsciidocLexer(CharStream input) {
    super(input);
  }

  public void startDelimBlock() {
    String s = getText().trim();
    delimBlockBoundary = s;
    if (s.startsWith("```"))
      delimBlockBoundary = "```";
  }

  public boolean isDelimBlockEnd() {
    return getText().trim().equals(delimBlockBoundary);
  }

  public void emitType(int type) {
    Token t = _factory.create(_tokenFactorySourcePair, type, null, _channel,
                              _tokenStartCharIndex, getCharIndex() - 1, _tokenStartLine,
                              _tokenStartCharPositionInLine);
    emit(t);
  }

  @Override public void emit(Token t) {
    tokenQueue.push(t);
    isBOL = t.getText().endsWith("\n");
  }

  @Override
  public Token nextToken() {
    if (tokenQueue.peek() != null) {
      return tokenQueue.remove();
    }

    super.nextToken();

    if (tokenQueue.peek() != null) {
      return tokenQueue.remove();
    }
    return null;
  }

}
