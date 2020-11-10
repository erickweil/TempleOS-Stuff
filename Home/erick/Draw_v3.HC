// Defines and globals
#define SCRN_SCALE		512
#define MAN_HEIGHT		125

#define CAM_START_X	0
#define CAM_START_Y	0
#define CAM_START_Z	0


public class WGame
{
  I64 cam_x,cam_y,cam_z;
  F64 cam_é;
  

};

WGame *DrawItWGame = NULL;

//WGame *game = WGameNew();

public WGame *WGameNew(CTask *task=NULL)
{//Create new Game context.
 //Don't forget these $MA-X+PU,"sizeof(CDC)",LM="Find(\"sizeof(CDC)\",\"/*\");View;"$.
  WGame *res;
  if (!task) task=Fs;
  res=CAlloc(sizeof(WGame),task);
  
  
  return res;
}


/*

       6*-----7*
      / |      |
     |  |     ||
     /  |    | |
    |   |    | |
   /    |   |  |
   |   4*-----5*
  /    |  /    |
 2*-----3*     |
  |   /  |    |
  |  /   |    |
  | |    |   /
  | |    |  /
  |'     | /
 0*-----1*//*


// Anti-clockwise

Mesh{
FALSE,
(-25,-25,-25),//0
(25,-25,-25),//1
(-25,25,-25),//2
(25,25,-25), //3
(-25,-25,25), //4
(25,-25,25),
(-25,25,25),
(25,25,25)//7
:
(YELLOW,0,1,2),(YELLOW,2,1,3),
(BROWN,2,6,4),(BROWN,2,4,0),
(GREEN,0,4,1),(GREEN,1,4,5),
(RED,1,7,3),(RED,1,5,7),
(CYAN,4,6,7),(CYAN,4,7,5),
(BLUE,2,3,6),(BLUE,3,7,6)
};

*/
U0 fillArray(I32 *a,...)
{
  I64 i;
  for(i=0;i<argc;i++)
  {
    a[i] = argv[i];
  }
}

//########################### MESH#############################
  I64 verts3D_count = 24;
  I64 tris3D_count = 48;
  I64 cw = 50;
  I32 verts3D[24];
  fillArray(verts3D,
  -cw,-cw,-cw, //0
   cw,-cw,-cw, //1
  -cw, cw,-cw, //2
   cw, cw,-cw, //3
  -cw,-cw, cw, //4
   cw,-cw, cw, //5
  -cw, cw, cw, //6
   cw, cw, cw  //7
  );

  I32 tris3D[48];
  fillArray(tris3D,
  YELLOW,0,1,2, YELLOW,2,1,3,
  BROWN,2,6,4,  BROWN,2,4,0,
  GREEN,0,4,1,  GREEN,1,4,5,
  RED,1,7,3,  RED,1,5,7,
  CYAN,4,6,7,  CYAN,4,7,5,
  BLUE,2,3,6,  BLUE,3,7,6);

  CD3I32 tri[3];

// Foreshortening function A.K.A. Z Divide for perspective
// Must set dc->transform
U0 CFTransform(CDC *dc,I64 *x,I64 *y,I64 *z)
{
  I64 zz;
  Mat4x4MulXYZ(dc->r,x,y,z);
  zz=SCRN_SCALE/3+*z;
  if (zz<1) zz=1;
  *x=SCRN_SCALE/2* *x/zz;
  *y=SCRN_SCALE/2* (*y+MAN_HEIGHT)/zz;
  *x+=dc->x;
  *y+=dc->y;
  *z+=dc->z;
}


U0 draw_cube(CDC *dc,I64 Px,I64 Py,I64 Pz)
{

  //draw(dc,poly);
  I64 i;
  for(i=0;i<tris3D_count/4;i++)
  {

    dc->color=tris3D[i*4+0];
     
    I64 v0 = tris3D[i*4+1];
    I64 v1 = tris3D[i*4+2];
    I64 v2 = tris3D[i*4+3];
    //Print("\n %d,%d,%d",v0,v1,v2);

        
    tri[0].x=verts3D[v0*3+0]+Px;
    tri[0].y=verts3D[v0*3+1]+Py;
    tri[0].z=verts3D[v0*3+2]+Pz;
        
    tri[1].x=verts3D[v1*3+0]+Px;
    tri[1].y=verts3D[v1*3+1]+Py;
    tri[1].z=verts3D[v1*3+2]+Pz;
        
    tri[2].x=verts3D[v2*3+0]+Px;
    tri[2].y=verts3D[v2*3+1]+Py;
    tri[2].z=verts3D[v2*3+2]+Pz;

    //GrFillTri0(dc,&tri[0],&tri[1],&tri[2]);
    GrFillPoly3(dc,3,tri);
              
  }

}




U0 DrawIt(CTask *task,CDC *dc)
{
  if(!DrawItWGame)
  {
    Print("No WGame set.");
  }
  WGame *g = DrawItWGame;
  //I64 *s2w,
  
  I64 cx=task->pix_width/2;
  I64 cy=task->pix_height/2;

  // Prepare
  DCDepthBufAlloc(dc);
  // Is that needed?
  //MemSet(panels_processed_bitmap,0,(map_width*map_height+7)>>3);
  // Transform Position
  //man_xx = ms.pos.x-Fs->pix_left-Fs->scroll_x -cx;
  //man_yy = ms.pos.y-Fs->pix_top-Fs->scroll_y -cy;
  
  Mat4x4TranslationEqu(dc->r,g->cam_x,g->cam_y,g->cam_z);

  g->cam_é = (-ms.pos.x/200.0) % ã*2;
  Mat4x4RotY(dc->r,g->cam_é);
  DCMat4x4Set(dc,dc->r);


  // Apply flags and Perspective transform
  dc->flags|=DCF_TRANSFORMATION;
  dc->transform=&CFTransform;
  dc->x=cx;
  dc->y=cy;
  dc->z=130;
  dc->color = RED;
  
  // Paint screen White
  DCFill(dc,WHITE);
  
  // Draw elems With Global pos Offsets
  draw_cube(dc,0,0,0);
  draw_cube(dc,0,0,150);
  draw_cube(dc,0,0,300);
  draw_cube(dc,0,0,450);
  draw_cube(dc,0,200,450);
  draw_cube(dc,-250,0,0);
}


U0 Init()
{

  DocClear;
  "$$BG,BLACK$$%h*c",TEXT_ROWS/2,'\n';
  cam_x=(CAM_START_X)*SCRN_SCALE;
  cam_y=(CAM_START_Y)*SCRN_SCALE;
  cam_z=(CAM_START_Z)*SCRN_SCALE;
  cam_é=0;

}



U0 MoveCamera(I64 x,I64 y,I64 z)
{
  x *= 5;
  y *= 5;
  z *= 5;
  cam_x -= x*Cos(cam_é)-z*Sin(cam_é);
  cam_y -= y;
  cam_z -= x*Sin(cam_é)+z*Cos(cam_é);
}


U0 MainLoop()
{
  I64 sc;
  
  SettingsPush; //See $LK,"SettingsPush",A="MN:SettingsPush"$
  Fs->text_attr=DKGRAY<<4+WHITE;
  AutoComplete;
  WinBorder;
  WinMax;
  DocCursor;
  Init;
  //Fs->animate_task=Spawn(&AnimateTask,NULL,"Animate",,Fs);
  //Fs->song_task=Spawn(&SongTask,NULL,"Song",,Fs);
  Fs->draw_it=&DrawIt;

  try {
    while (TRUE) {
      switch (GetKey(&sc)) {
	case CH_SPACE:
          MoveCamera(0,1,0);
	  break;
	case '\n':
	  Init;
	  break;
	case CH_ESC:
	case CH_SHIFT_ESC:
	  goto fs_done;
	case 0:
	  switch (sc.u8[0]) {
	    case SC_CURSOR_RIGHT:
              MoveCamera(1,0,0);
	      break;
	    case SC_CURSOR_LEFT:
              MoveCamera(-1,0,0);
	      break;
	    case SC_CURSOR_UP:
	      MoveCamera(0,0,1);
	      break;
	    case SC_CURSOR_DOWN:
	      MoveCamera(0,0,-1);
	      break;
	  }
	  break;
      }
    }
  fs_done:
  } catch
  PutExcept;
 
  DocClear;
  SettingsPop;
//CleanUp;
  MenuPop;
  
}

MainLoop;
