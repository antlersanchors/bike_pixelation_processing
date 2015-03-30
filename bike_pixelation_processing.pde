/**
 * Pixelator
 * based on "Mirror" by Daniel Shiffman
 *
 * 2015 © Akshay Verma, Michael Owen-Liston, Riccardo Caereser
 */

import processing.video.*;
import processing.serial.*;

// Size of each cell in the grid
int cellSize;
// Number of columns and rows in our system
int cols, rows;
int r, g, b;
// Variable for capture device
Capture video;

// hall sensor arduino
Serial arduino1;
// pixel matrix arduino
Serial arduino2;
int index;

int resVal;
int maxRes;

void setup() {
  size(800, 800);
  frameRate(30);

  resVal = 1;

  // VALUE FOR THE MAXIMUM RESOLUTION
  maxRes = 16;
  
  cols = resVal;
  rows = resVal;
  cellSize = width/cols;
  colorMode(RGB, 255, 255, 255, 100);


  println(Serial.list());
  // hall sensor arduino
  arduino1 = new Serial(this, Serial.list()[7], 9600);
  // pixel matrix arduino
  arduino2 = new Serial(this, Serial.list()[6], 115200); // ! Make sure to set the correct arduino2 index here !

  arduino2.clear();

  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, width, height, 5);

  // Start capturing the images from the camera
  video.start();

  background(0);

}


void draw() {

   if ( arduino1.available() > 0) {  // If data is available,
    resVal = int(arduino1.read());         // read it and store it in resVal
    println("resVal raw: " + resVal);
    resVal = constrain(resVal, 1, maxRes); 
    println("resVal mapped: " + resVal);
    
    cols = resVal;
    rows = resVal;
    cellSize = width/cols;
     
  }

  if (video.available()) {
    video.read();
    video.loadPixels();

    // Begin loop for columns
    for (int j = 0; j < rows; j++) {
      // Begin loop for rows
      for (int i = 0; i < cols; i++) {
        index = i + j*cols;
        // Where are we, pixel-wise?
        int x = i*cellSize;
        int y = j*cellSize;
        int loc1 = (video.width - x - 1) + y*video.width; // Reversing x to mirror the image
        int loc2 = ((video.width - x - 1) + y*video.width) - 1;
        int loc3 = (video.width - x - 1) + ((y+1)*video.width);
        int loc4 = ((video.width - x - 1) + ((y+1)*video.width)) - 1;

        r = int((red(video.pixels[loc1]) + red(video.pixels[loc2]) + red(video.pixels[loc3]) + red(video.pixels[loc4])) / 4);
        g = int((green(video.pixels[loc1]) + green(video.pixels[loc2]) + green(video.pixels[loc3]) + green(video.pixels[loc4])) / 4);
        b = int((blue(video.pixels[loc1]) + blue(video.pixels[loc2]) + blue(video.pixels[loc3]) + blue(video.pixels[loc4])) / 4);
        color c = color(r, g, b);
        
        // put the values in a string and send them over to Processing
        // String sendValues = "i" + index + ", " + r + ", " + g + ", " + b + "\n";

        String sendValues = index + "#" + hex(c, 6);
        arduino2.write(sendValues);
        arduino2.write(10);

        // clearing the arduino2 seems to help with things on the other end?
        arduino2.clear();

        // Code for drawing a single rect
        pushMatrix();
          translate(x+cellSize/2, y+cellSize/2);
          rectMode(CENTER);
          fill(c);
          noStroke();
          rect(0, 0, cellSize, cellSize);
        popMatrix();
        
        delay(5);
      }
    }
  }
}

