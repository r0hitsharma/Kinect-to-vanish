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
  black = createImage(2, 2, RGB);
  black.loadPixels();
  for (int i =0; i<black.width*2; i++) {
    black.pixels[i]=color(0);
  }
  black.updatePixels();

  context = new SimpleOpenNI(this);

  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }

  context.enableScene();
  context.enableRGB();

  background(200, 0, 0);
  size(context.sceneWidth(), context.sceneHeight()); 

  end = new PImage();
  end2 = new PImage();
  //back = new PImage();
  //colorBuffer = new PImage();
  colorBuffer = createGraphics(width, height, P2D);

  frameRate(30);
}

String bg = "back_cache.jpg";

void draw()
{
  background(210);
  // update the cam
  context.update();

  back = loadImage(bg);

  if (back != null)
    image(back, 0, 0);

  // draw irImageMap
  end = context.sceneImage();
  end.filter(POSTERIZE, 2);
  if (toggle)
  {
    for (int x=0; x<width; x++) {
      for (int y=0; y<width; y++) {
        if (end.get(x, y) == color(255))
          end.set(x, y, 0);
      }
    }
  }

  end2 = context.rgbImage();
  if(pause){
    back = end2;
    image(back, 0,0);
    saveFrame(bg);
    pause = false;
  }
  
  if (end2 != null)
    end2.mask(end);
  image(end2, 0, 0);
}

void keyPressed() {
  if (key == ' ') {
    toggle=!toggle;
    println("toggled");
  }

  if (key == 'u') {
    updateBg();
    println("bg updated");
  }
}

void updateBg() {
  pause = true;
  /*
  back = new PImage();
  back = context.rgbImage();
  
  colorBuffer.beginDraw();
  colorBuffer.image(back, 0, 0);
  colorBuffer.endDraw();
  */
  
  bg = "back_cache" + millis() + ".jpg";
  //colorBuffer.save(bg);
  //back = colorBuffer;
  //image(colorBuffer, 0, 0);

  //back.save(bg);
  println("bg updated3232");
}

