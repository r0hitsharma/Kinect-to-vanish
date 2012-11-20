/*
Kinect to Vanish by Antoni Kaniowski and Rohit Sharma
http://ciid.dk/education/portfolio/idp12/courses/generative-design/projects/kinect-to-vanish/

------------------------------------------------------------------------------

This code is based on the SceneDepth example in OpenNI/Kinect library
 You would need the library in order to use this code
 http://code.google.com/p/simple-openni
 
 The Scene Depth example basically tracks the human form and provides a colored Depth Map of pixels in the human form
 */

import SimpleOpenNI.*;

SimpleOpenNI  context;
boolean toggle = true;
boolean pause = false;
PImage end;
PImage end2;
PImage black;
PImage back;
PGraphics colorBuffer;

void setup()
{
  //First we create a perfectly black image, which we would use to 'subtract' the black pixels from the Depth Scene Map using the POSTERIZE filter
  black = createImage(2, 2, RGB);
  black.loadPixels();
  for (int i =0; i<black.width*2; i++) {
    black.pixels[i]=color(0);
  }
  black.updatePixels();

  context = new SimpleOpenNI(this);

  //Enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }

  //We need both the Depth Scene Map and the RGB map to be enabled for this to work
  context.enableScene();
  context.enableRGB();

  //Set the background to something other than Black so you notice when things don't work
  background(200, 0, 0);
  size(context.sceneWidth(), context.sceneHeight()); 

  end = new PImage();  //This will be used to save the Depth Scene Map
  end2 = new PImage();  //This will be used to save the RGB Map
  colorBuffer = createGraphics(width, height, P2D);

  frameRate(30);
}

//This is the file name for the image we use to store the background
String bg = "back_cache.jpg";

void draw()
{
  background(210);
  //Update the camera
  context.update();

  //Load and place the saved background image
  back = loadImage(bg);

  if (back != null)
    image(back, 0, 0);

  //Store the IR Depth Scene
  end = context.sceneImage();

  //Remove the pixels which don't have depth information related to the human form
  end.filter(POSTERIZE, 2);

  //Toggle switches the effect on and off
  if (toggle)
  {
    for (int x=0; x<width; x++) {
      for (int y=0; y<width; y++) {
        if (end.get(x, y) == color(255))
          end.set(x, y, 0);
      }
    }
  }

  //Store the RGB Image
  end2 = context.rgbImage();

  //Pausing is done by saving the RGB pixels as the bakground
  if (pause) {
    back = end2;
    image(back, 0, 0);
    saveFrame(bg);

    //Unpause otherwise the background will keep getting refreshed, basically just putting the lived video feed on plain and simple
    pause = false;
  }

  //This is where it all comes together, the Depth map pixels (end) are applied as a map on the RGB pixels (end2) to create a layer of just the pixels corresponding to the human figures, which are augmented above the static background (bg)
  if (end2 != null)
    end2.mask(end);
  image(end2, 0, 0);
}

void keyPressed() {
  //To pause the video feed on a frame
  if (key == ' ') {
    toggle=!toggle;
    println("toggled");
  }

  //On pressing 'u', the colored image is stored as the background on which the human RGB pixels are pasted on top
  if (key == 'u') {
    updateBg();
    println("Background updated #1");
  }
}

void updateBg() {
  //This process takes a bit of time so it's best to pause evething meanwhile
  pause = true;

  bg = "back_cache" + millis() + ".jpg";
  println("Background updated #2");
}

