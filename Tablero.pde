import TUIO.*;
import oscP5.*;
import netP5.*;

TuioProcessing tuioClient;
OscP5 oscP5;
NetAddress myRemoteLocation;


BotonTUIO inicioTUIO, atrasTUIO, reset;
ToggleTUIO on_off;
ToggleTUIO[][] grid_paso = new ToggleTUIO[4][16];
V_Scrollbar[] v_barras = new V_Scrollbar[10];
RadioTUIO[][] ritmos = new RadioTUIO[4][8];
RadioTUIO[][] bancos = new RadioTUIO[4][5];

//TecladoTUIO[] teclado = new TecladoTUIO[12];

int l_t = 1200;  // largo tablero
int a_t = 900; // alto tablero
int metro_x;
int i,j, espacio;
int pantalla=0;
float cursor_size = 15;
float table_size = 760;
float scale_factor = 1;
float obx, oby;



long[] tiempos = new  long[3];//Arreglo de tiempos para double-click

PImage UNAM,FI, bkg;
PFont f,f2,f3;

void setup() {
  size(l_t, a_t);  
  oscP5 = new OscP5(this,9002);
  myRemoteLocation = new NetAddress("192.168.0.2",9002);
  
 
  
  tiempos[0]=0; //Comienza en tiempo nulo
  tuioClient  = new TuioProcessing(this);
  UNAM = loadImage("UNAM.jpg" );
  FI = loadImage("FI.jpg" );
  bkg = loadImage("IIMAS.jpg");
 
  espacio = height /65;

  scale_factor = height/table_size;

  //Se definen botones
  inicioTUIO = new BotonTUIO(width - width/10, height*0.858, height/20,color(204), color(255,0,0), color(0));
  atrasTUIO = new BotonTUIO(width/18, height*0.858, height/20,color(204), color(255,0,0), color(0));
  reset = new BotonTUIO(2*width/18, height*0.858, height/20,color(204), color(255,0,0), color(0));
  on_off  = new ToggleTUIO(3*width/18 , height*0.858 , height/20, height/20,color(204),color(255,0,0),color(0));
   
    for (int i=0;i<4;i++) {
      for (int j=0;j<16;j++) {
      grid_paso[i][j]=new ToggleTUIO((j+1)*width/18 , (i+1)*height/16 + espacio, height/20, height/20,color(204),color(255,0,0),color(0));
        if(j<8){
        ritmos[i][j]=new RadioTUIO((j+1.2) * width/18,(i+2.2)*height/16 + espacio ,height/40,color(255), color(0),j,i, 8, ritmos);
        }
        
        if(j>10){
        bancos[i][j-11]=new RadioTUIO((j-12+1.2) * width/18 + width/1.5 ,(i+2.2)*height/16 + espacio ,height/40,color(155), color(0),j-11,i, 5, bancos);
        }    
      }           espacio = espacio + height /20; }
      
    espacio = 0;
      
    for (int i=0;i<8;i++) {  
      //volumen    
      if(i<4){
      v_barras[i]=new V_Scrollbar((i+1)*width/25 + 20,6.5*height/12 + 30,height/40,height/4,1,12, color(0),color(155),color(255));
      v_barras[i].pos = 7*height/12;
      
      }
      //reverb
      if(i>3){
      v_barras[i]=new V_Scrollbar((i+1)*width/25 + 20,6.5*height/12 + 30,height/40,height/4,1,12, color(155),color(255),color(0));
      v_barras[i].pos = 9.6*height/12;
      }  
    }
    
    //tempo
     v_barras[8]=new V_Scrollbar(0.84*width,6.5*height/12 + 30,height/40,height/4,1,12, color(155),color(255),color(0));
     v_barras[8].pos = 8*height/12;
     //master
     v_barras[9]=new V_Scrollbar(0.92*width,6.5*height/12 + 30,height/40,height/4,1,12, color(0),color(155),color(255));
     v_barras[9].pos = 7*height/12;

   //  for (int i=0;i<12;i++) {  
     // teclado[i]=new TecladoTUIO((i+0.5)*width/12 + width/2,6.5*height/12,height/20,color(255),color(155),i, teclado);
   // }
    
    
    
   // for (int i=0;i<4;i++) {    
     // ritmos[i]=new RadioTUIO((i+1) * width/17,height/6.5,height/40,color(255), color(0),i, ritmos);
   // }
  
}

void draw() {
  background(204);
  stroke(255);
  switch(pantalla) {  
  case 0:
    pantallaA();
    break;  
  case 1:
    pantallaB();
    break;
  }
}

///////////////Metodo para dibujar eventos y trayectoria del cursor
void dibujaEventosTUIO() {
  Vector tuioCursorList = tuioClient.getTuioCursors();
  for (int i=0;i<tuioCursorList.size();i++) {
    TuioCursor tcur = (TuioCursor)tuioCursorList.elementAt(i);    
    Vector pointList = tcur.getPath();    
    stroke(192,192,192);
    fill(tcur.getScreenX(width)/4,tcur.getScreenY(height)/4, tcur.getScreenX(width)/50);
    ellipse( tcur.getScreenX(width), tcur.getScreenY(height),width/50 + tcur.getScreenX(width) / 50,width/50 + tcur.getScreenY(width)/50);
    textAlign(TOP, LEFT);
    text("X = " + tcur.getScreenX(width),width - width/5, height*0.05);
    text("Y = " + tcur.getScreenY(height),width - width/5, height*0.1);
    fill(0);  }}

///////////////Metodos TUIO
void addTuioCursor(TuioCursor tcur) {
  tiempos[0]=tiempos[1];
  tiempos[1]=System.currentTimeMillis();
  tiempos[2]=tiempos[1]-tiempos[0];
  obx=tcur.getX()*width; 
  oby=tcur.getY()*height;}

void updateTuioCursor (TuioCursor tcur) {
  obx=tcur.getX()*width;
  oby=tcur.getY()*height;

}

void removeTuioCursor(TuioCursor tcur) {
  println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  obx=oby=0;}

void refresh(TuioTime bundleTime) { 
  redraw();}

///

void pantallaA() {
  OscMessage mReset = new OscMessage("/reset"); //Pone en 0 el arreglo en PUREdata
  mReset.add(0);
  oscP5.send(mReset, myRemoteLocation); 
  
//f = loadFont("JasmineUPCBold-48.vlw");
  f = loadFont("BrowalliaNew-48.vlw");
  f2 = loadFont("BrowalliaNew-Bold-48.vlw");
 
  background(255);
  image(UNAM, width/30, height*0.03);
  image(FI, width - width/5, height*0.03);

  textFont(f);
  textAlign(LEFT);
  fill(1);
  textAlign(CENTER, TOP);
  text("Facultad de Ingeniería",width/2,height*0.45);
//  text("Proyecto de Tesis ",width/2,height*0.4);  
  text("Desarrollo de interfaz multi-táctil mediante el fenómeno de FTIR", width/2, height*0.55);
  
  textFont(f2);
  text("Universidad Nacional Autónoma de México",width/2, height*0.4);
  text("Iniciar",width - width/6.8, height*0.858);

  atrasTUIO.pressed=false;
  inicioTUIO.pressed=false;

  fill(obx*25,oby*25,0);

  dibujaEventosTUIO();
  inicioTUIO.display();
  inicioTUIO.update();



  if (inicioTUIO.pressed==true && inicioTUIO.over==true){
  atrasTUIO.over=atrasTUIO.pressed=false;  
  tiempos[0]=0;    // reV - JMB
  pantalla=1; 
  reset();
  
  
 // for (int i=0;i<4;i++) {
   //     ritmos[i][0].checked = true;
     //   bancos[i][0].checked = true;
 // } 
 

 
  }
}


void pantallaB() {
  String send_s, mensaje;
  f3 = loadFont("BrowalliaNew-Bold-30.vlw");
  
  OscMessage mReset = new OscMessage("/reset");
  OscMessage o_toggle = new OscMessage("/toggle");
  OscMessage onOff = new OscMessage("/onOff");
  
  stroke(0);
  fill(0,255,0);
  ellipse((metro_x+1)*width/18, height/16, 20, 20);
  
  textFont(f3);
  textAlign(LEFT);
  fill(1);
  textAlign(LEFT, BOTTOM);
  text(" <---",width/18, height*0.94);
  text("reset",2*width/18, height*0.94);
  text("onOff",3*width/18, height*0.94);
  text("tempo",0.84*width, height*0.87);
  text("m_vol",16.5*width/18, height*0.87);
  text("vol",width/18, 6.8*height/12);
  text("rev",4*width/18, 6.8*height/12);
  
  dibujaEventosTUIO();  
  atrasTUIO.display();
  atrasTUIO.update();
  reset.display();
  reset.update();
  on_off.display();
  on_off.update();
  
  if (atrasTUIO.pressed==true && atrasTUIO.over==true){
  inicioTUIO.over=inicioTUIO.pressed=false;  
  tiempos[0]=0; // reV - JMB
  pantalla=0;
  reset();
  
  onOff.add(0);
  oscP5.send(onOff, myRemoteLocation); 
 }
           
  
  
  //RESET
           
  if (reset.pressed==true && reset.over==true){
  reset();
  mReset.add(1);
  oscP5.send(mReset, myRemoteLocation); 
  
  reset.pressed=false;          }

  textFont(f);
  fill(0);
  textAlign(RIGHT);

 //for (int i=0;i<4;i++) {
   
  // ritmos[i].displayR();
   //ritmos[i].press(obx, oby);
   
 //}


  // TUIO - Button - Grid   / RadioTUIO
 for (int i=0;i<4;i++) {
      for (int j=0;j<16;j++) {
        grid_paso[i][j].display();
        grid_paso[i][j].update();        
          if( grid_paso[i][j].over==true) {
          o_toggle.add(i);
          o_toggle.add(j);
          o_toggle.add(grid_paso[i][j].on);
          oscP5.send(o_toggle, myRemoteLocation);    
          print(o_toggle);     
          //tiempos[0]=0; 
          }      
      if(j<8){
        ritmos[i][j].displayR();
        mensaje = "/ritmo";
        ritmos[i][j].press(obx, oby, mensaje);      

        }
        
       if(j>10){
        bancos[i][j-11].displayR();
        bancos[i][j-11].press(obx, oby,"/banco");      }

  }        }

// for (int i=0;i<12;i++) {
  //      teclado[i].displayR();
    //    teclado[i].press(obx, oby);  
 // }
 
 
 
  if (on_off.over==true){
  onOff.add(on_off.on);
  oscP5.send(onOff, myRemoteLocation); 
  reset.pressed=false;          }
  
  
           
 for (int i=0;i<10;i++) {
  v_barras[i].update(i);
  //
  v_barras[i].display();}
      
}





void reset(){ 
    
  on_off.on = true;
   for (int i=0;i<4;i++) {
        ritmos[i][0].checked = true;
        bancos[i][0].checked = true;
        
        for (int j=0;j<16;j++) {
          grid_paso[i][j].on = false;
          if(j<8 && j !=0){
          ritmos[i][j].checked = false;   }
        
          if(j>10){
          bancos[i][j-11].checked = false;
          }
      bancos[i][0].checked = true;
  }}
 
 
     for (int i=0;i<8;i++) {  
      //volumen    
      if(i<4){
      v_barras[i].pos = 7*height/12;      }
      //reverb
      if(i>3){
      v_barras[i].pos = 9.6*height/12;}   }
    //tempo
     v_barras[8].pos = 8*height/12;
     //master
     v_barras[9].pos = 7*height/12;
     
     
 // OscMessage mReset = new OscMessage("/reset"); //Pone en 0 el arreglo en PUREdata

}


////////////////////////////////////////////V_Scrollbar
class V_Scrollbar {
  float x, y; // The x- and y-coordinates
  float sw, sh; // Width and height of V_Scrollbar
  float pos; // Position of thumb
  float posMin, posMax; // Max and min values of thumb
  boolean rollover; // True when the mouse is over
  boolean locked; // True when its the active V_Scrollbar
  float minVal, maxVal; // Min and max values for the thumb
  color fondo;
  color marker;
  color hold;
  

  V_Scrollbar (float xp, float yp, float w, float h, float miv, float mav,color f, color m, color hl) {
    x = xp;
    y = yp;
    sw = w;
    sh = h;
    minVal = miv;
    maxVal = mav;
    pos = y + sh/2 - sw/2;
    posMin = y;
    posMax = y + sh - sw;
    fondo = f;
    marker = m;
    hold = hl;
    
  }

  // Updates the over boolean and the position of the thumb
  void update(int slider ) {
    
    //OscMessage scroll = new OscMessage("/slider");
    if (over(obx, oby) == true) {
      rollover = true;
      pos = constrain(oby-sw/2, posMin, posMax);
      OscMessage o_scroll = new OscMessage("/scroll");
      o_scroll.add(slider);
      o_scroll.add(pos-posMax);
      oscP5.send(o_scroll, myRemoteLocation);  
      println(pos);
    } 
    else {
      rollover = false;
    }
    
  }
  // Locks the thumb so the mouse can move off and still update
  void press(int mx, int my) {
    if (rollover == true) {
      locked = true;
    } 
    else {
      locked = false;
    }}
 
  // Resets the V_Scrollbar to neutral
  void release() {
    locked = false;
  }
 
  // Returns true if the cursor is over the V_Scrollbar
  boolean over(float mx, float my) {
    if ((mx > x) && (mx < x+sw) && (my > y) && (my < y+sh)) {
      return true;
    } 
    else {
      return false;}  }

  // Draws the V_Scrollbar to the screen
  void display() {
    fill(marker);
    rect(x, y, sw, sh);
    if ((rollover==true) || (locked==true)) {
      fill(fondo);
    } 
    else {
      fill(hold);
    }
    rect(x, pos, sw, sw); }
  // Returns the current value of the thumb
  float getPos() {
    float scalar = sh/(sh-sw);
    float ratio = (pos - y) * scalar;
    float offset = minVal + (ratio/sw * (maxVal-minVal));
    return offset;  }}

/////////////////////////////////////////////BotonTUIO
class BotonTUIO {
  float x, y; 
  float size; 
  color baseGray; 
  color overGray; 
  color pressGray; 
  boolean over = false; 
  boolean pressed = false; 
  
  BotonTUIO(float xp, float yp, float s, color b, color o, color p) {
    x = xp;
    y = yp;
    size = s;
    baseGray = b;
    overGray = o;
    pressGray = p;  }
  
  void update() {
    if ((obx >= x) && (obx <= x+size) &&
      (oby >= y) && (oby <= y+size)) {
      over = true;
    } 
    else {
      over = false;
    }
  //  if(tiempos[2]<500 && over==true) {
    pressed=true;} //}
  
  void display() {
    if (pressed == true) {
      fill(pressGray);
    } 
    else if (over == true) {
      fill(overGray);
    } 
    else {
      fill(baseGray);
    }
    stroke(1);
    rect(x, y, size, size);
  }

}




/////////////////////////////////////////////ToggleTUIO
class ToggleTUIO {
  float x, y, alto_b, ancho_b; 
  color baseGray; 
  color overGray; 
  color pressGray; 
  color triplet;
  boolean over = false; 
  boolean on = false; 

  
  ToggleTUIO(float xp, float yp, float ancho, float alto, color b, color o, color p) {
    x = xp;
    y = yp;

    alto_b = alto;
    ancho_b= ancho;
    baseGray = b;
    overGray = o;
    pressGray = p;
    }
  
  void update() {
    if ((obx >= x) && (obx <= x + ancho_b) &&
      (oby >= y) && (oby <= y + alto_b)) {
      over = true;
//      if(tiempos[2]>100 && tiempos[2]<1000) {
        on= !on;//}
      } 
    else {
      over = false;
    }


    }
    
  void display() {

    if (on == true) {
      fill(pressGray);
    } 
    else if (over == true) {
      fill(overGray);
    } 
    else {
      fill(baseGray);
    }
    stroke(0);
    rect(x, y, ancho_b, alto_b);
  }

}


 class RadioTUIO{
  float x, y; // The x- and y-coordinates of the rect
  float size, dotSize; // Dimension of circle, inner circle
  color baseGray, dotGray; // Circle gray value, inner gray value
  boolean checked = false; // True when the button is selected
  int me,cols, my_row; // ID number for this Radio object
  RadioTUIO[][] others; // Array of all other Radio objects

    RadioTUIO(float xp, float yp, float s, color b, color d, int m, int mr, int columns, RadioTUIO[][] o) {
    x = xp;
    y = yp;
    size = s;
    dotSize = size - size/3;
    baseGray = b;
    dotGray = d;
    others = o;
    cols=columns;
    my_row = mr;
    me = m;
  }

  // ACTUALIZA VALOR PRESS/TRUE/FALSE
    boolean press(float mx, float my, String message) {
      OscMessage o_ritmo = new OscMessage(message);
    
    
		if (dist(x, y, mx, my) < size/2) {
      

    
  
    checked = true;
    
    o_ritmo.add(my_row);
    o_ritmo.add(me);
           // o_ritmo.add(ritmos[i][j].checked);
    
    oscP5.send(o_ritmo, myRemoteLocation);
    
      for (j=0; j < cols; j++){
        if (j != me) {
        others[my_row][j].checked = false; }
      }
    
    return true;
    } else {
    return false;
    }
    }

  // DIBUJA ELEMENTO
  void displayR() {
    stroke(0);
    fill(baseGray);
    ellipse(x, y, size, size);
    if (checked == true) {
      fill(dotGray);
      ellipse(x, y, dotSize, dotSize);
    }
  }
  }
  
class TecladoTUIO{
  
  float x, y; // The x- and y-coordinates of the rect
  float size, dotSize; // Dimension of circle, inner circle
  color baseGray, dotGray; // Circle gray value, inner gray value
  boolean checked = false; // True when the button is selected
  int me,cols, my_row; // ID number for this Radio object
  TecladoTUIO[] others; // Array of all other Radio objects

    TecladoTUIO(float xp, float yp, float s, color b, color d, int m,  TecladoTUIO[] o) {
    x = xp;
    y = yp;
    size = s;
    dotSize = size - size/3;
    baseGray = b;
    dotGray = d;
    others = o;
    me = m;
  }

  // ACTUALIZA VALOR PRESS/TRUE/FALSE
		boolean press(float mx, float my) {
		    if ((obx >= x) && (obx <= x + size/2) &&    (oby >= y) && (oby <= y + size*2)) {
		checked = true;
		for (int i = 0; i < others.length; i++) {
		if (i != me) {
		others[i].checked = false;
		}
		}
		return true;
		} else {
		return false;
		}
		}

  // DIBUJA ELEMENTO
  void displayR() {
    stroke(0);
    fill(baseGray);
    rect(x, y, size, size*4);
    if (checked == true) {
      fill(dotGray);
      rect(x, y, dotSize, dotSize*4);
    }
  }
  }


void oscEvent(OscMessage theOscMessage) 
{  
  
  //print("\nreceived an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //println(" typetag: "+theOscMessage.typetag());
  
  // check the address pattern and the typetag against an
  // expected pattern. 
  if(theOscMessage.addrPattern().equals("/metro") && 
     theOscMessage.typetag().equals("i")) {
      // checking both, the address pattern and the typetag, 
      // guarantees safe value parsing and data transfer.
      //println("got a /test message with typetag i (int)");
      // if the value at index 0 is not of type int, oscP5 will thrown
      // an error message of type java.lang.reflect.InvocationTargetException
      int a = theOscMessage.get(0).intValue();
      //println("value at index 0 (int expected) : "+a);
      metro_x=a;

  }

}
