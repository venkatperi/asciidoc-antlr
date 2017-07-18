package com.vperi.util;

import java.awt.Image;
import java.awt.image.RenderedImage;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

import org.ghost4j.document.PSDocument;
import org.ghost4j.renderer.SimpleRenderer;


class PS2Image {
  def src 
  def dest
  def resolution = 300
  def format = 'png'

  def convert() {
    def doc = new PSDocument();
    doc.load(new File(src));
    def renderer = new SimpleRenderer();
    renderer.resolution = resolution;
    images = renderer.render(doc);

    ImageIO.write(images[0], format, new File(dest));
  }
}

