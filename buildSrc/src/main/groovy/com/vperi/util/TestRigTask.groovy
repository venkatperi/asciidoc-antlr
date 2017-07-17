package com.vperi.util;

import org.gradle.api.tasks.JavaExec
import org.gradle.api.tasks.TaskAction


import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FilenameUtils;


class TestRigTask extends JavaExec {
  def grammar 
  def startRule 
  def tree = true
  def image = true
  def tokens = false
  def trace = false
  def src
  def rigDir = 'build/rig'

  public TestRigTask() {
    super()

    main = "org.antlr.v4.gui.TestRig"
  }

  @Override
  public void exec() {
    def baseName = FilenameUtils.removeExtension(src.name);
    def list = [grammar, startRule]
    if (tree) list += '-tree'
    if (image) {
      list += '-ps'
      new File(rigDir).mkdirs()
      def psName = "${rigDir}/${baseName}.ps"
      list += psName
    }

    if (trace) list += '-trace';
    if (tokens) list += '-tokens';
    list += src.absolutePath;
    
    args list
    super.exec();
  }

}

