import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class path extends PApplet {

BufferedReader reader;
String line;
boolean start = false;


class Foo {
  int x;
  int y;
  Foo() {
    x = -100;
    y = -100;
  }
  Foo(int xx, int yy) {
    x = xx;
    y = yy;
  }
  public void display() {
    ellipse(x, y, 10, 10);
  }
}

public void setup() {
  // Open the file from the createWriter() example
  
  translate(30, 7);
  background(255);
  reader = createReader("../path.txt");
  PImage img = loadImage("timsGrad.png");
  image(img, 0, 0);
  strokeWeight(1);
  stroke(255, 0, 0);
  fill(255, 0, 0);
  String text = "Wind Direction";
  //textSize(30);
  //text(text, width/2 - textWidth(text)/2 +3, height-25);
  //text(text, 0, height/2);

  fill(255);
}

public void draw() {
  translate(30, 7);

  if (start) {
    //int x = 0;
    //int y = 0;
    Foo f = new Foo();
    //stroke(color(255, 0, 0));


    try {
      line = reader.readLine();
    } 
    catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
    if (line == null) {
      // Stop reading because of an error or file is empty
      noLoop();
    } else {
      String[] pieces = split(line, " ");
      //stroke(color(255, 0, 0));
      //println(pieces[0]);
      if (pieces[0].equals("color")) {
        println("Here: " + pieces[1]);
        String[] tmp = split(pieces[1], ",");
        stroke(color(PApplet.parseInt(tmp[0]), PApplet.parseInt(tmp[1]), PApplet.parseInt(tmp[2])));
      } else {
        f.x = PApplet.parseInt(pieces[0]);
        f.y = 222-PApplet.parseInt(pieces[1]);
        //f.y = int(pieces[1]);
      }
    }
    f.display();
  }
}

public void keyPressed() {
  start = true;
}

  public void settings() {  size(430, 235); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "path" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
