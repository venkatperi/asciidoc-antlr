//@Grapes( @Grab(group='com.github.julianthome', module='inmemantlr-api', version='1.3.8'))

import java.io.File;

import org.snt.inmemantlr.GenericParser;
import org.snt.inmemantlr.exceptions.*;
import org.snt.inmemantlr.listener.DefaultListener;

class Main {


  static void main(String... args) {
    def cwd = System.getProperty("user.dir")

    def files = [ 
      new File(cwd + "/src/main/antlr/AsciidocLexer.g4"),
      new File(cwd + "/src/main/antlr/AsciidocParser.g4")
    ] as File[];

    def gp = new GenericParser(files);
    def contents = new File(args[0]).text;
    gp.setListener(new DefaultListener());
    gp.compile();

    def ctx = gp.parse(contents);
  }

}
