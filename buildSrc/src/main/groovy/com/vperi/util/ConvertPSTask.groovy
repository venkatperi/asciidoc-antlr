package com.vperi.util;

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction

import java.awt.Image;
import java.awt.image.RenderedImage;
import java.io.File;
import java.io.IOException;
import java.util.List;

import javax.imageio.ImageIO;

import org.ghost4j.document.PSDocument;
import org.ghost4j.renderer.SimpleRenderer;
import org.apache.commons.io.FilenameUtils;


class ConvertPSTask extends DefaultTask {
  def src 
  def resolution = 300
  def format = 'png'

  @TaskAction
  def convert() {
    try {
      def doc = new PSDocument();
      doc.load(src);
      def renderer = new SimpleRenderer();
      renderer.resolution = resolution;
      images = renderer.render(doc);

      def baseName = FilenameUtils.removeExtension(src.name);
      ImageIO.write(images[0], format, new File(baseName  + '.' + format));
    }
    catch (Exception e) {
      println e.message
    }
  }
}

