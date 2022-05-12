
// Defines and globals
#define SCRN_SCALE		512
#define SCRN_ZOFF		1
#define MAN_HEIGHT		0   //125

#define CAM_START_X	4
#define CAM_START_Y	8
#define CAM_START_Z	8

#define MAP_X	16
#define MAP_Y	16
#define MAP_Z	16
#define MAP_SCALE	32

#define AIR	0
#define GRASS	1
#define DIRT	2
#define STONE	3
#define BEDROCK	4
#define WOOD	5
#define WATER	6
#define LAVA	7
#define SNOW	8
#define LEAVES	9
#define UNK1	10


I64 cam_x,cam_y,cam_z;
I64 cam_blockx,cam_blocky,cam_blockz;
F64 cam_é,cam_é2;

I64 cam_vx,cam_vy,cam_vz;
I64 gravity = 1;


U8 *mapgrid;

//                            N    Stride
#define CUBE_VERTS	24 // 8	 * 3
#define CUBE_TRIS	36 // 12 * 3
#define CUBE_TYPES	66 // 11 * 6

I32 verts3D[CUBE_VERTS];
I32 tris3D[CUBE_TRIS];
U8  cubesColors[CUBE_TYPES];
U0 fillArrayI32(I32 *a,...)
{
  I64 i;
  for(i=0;i<argc;i++)
  {
    a[i] = argv[i];
  }
}
U0 fillArrayU8(U8 *a,...)
{
  I64 i;
  for(i=0;i<argc;i++)
  {
    a[i] = argv[i];
  }
}

CD3I32 tri[3];


// Foreshortening function A.K.A. Z Divide for perspective
// Must set dc->transform
U0 CFTransform(CDC *dc,I64 *x,I64 *y,I64 *z)
{
  I64 zz;
  Mat4x4MulXYZ(dc->r,x,y,z);
  zz=SCRN_ZOFF+*z;
  if (zz<1) zz=1;
  *x=SCRN_SCALE/2* *x/zz;
  *y=SCRN_SCALE/2* (*y+MAN_HEIGHT)/zz;
  *x+=dc->x;
  *y+=dc->y;
  *z+=dc->z;
}


U0 draw_cube(CDC *dc,I64 Px,I64 Py,I64 Pz,I64 t,I64 flags=0xFFF)
{
  //dc->color=GREEN;
     
  //draw(dc,poly);
  I64 i;
  for(i=0;i<CUBE_TRIS/3;i++)
  {
    if((flags&(1<<i))!=0)
    {
    dc->color = cubesColors[6*t+(i/2)];
    
    I64 v0 = tris3D[i*3+0];
    I64 v1 = tris3D[i*3+1];
    I64 v2 = tris3D[i*3+2];
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

}



U0 Physics()
{
  if(cam_blockx >= 0 && cam_blockx < MAP_X &&
    cam_blocky >= 1 && cam_blocky < MAP_Y &&
    cam_blockz >= 0 && cam_blockz < MAP_Z)
  {
    
    U8 ground = mapgrid[cam_blockz*MAP_Y*MAP_X + cam_blocky*MAP_X + cam_blockx];
    U8 aboveground = mapgrid[cam_blockz*MAP_Y*MAP_X + (cam_blocky-1)*MAP_X + cam_blockx];
    if(cam_vy < 0 || ground == AIR || ground == WATER)
    {
      cam_vy += gravity; 
    }
    else if(aboveground != AIR && aboveground != WATER)
    {
      cam_vy -= gravity*5;
    }
    else
    {
      cam_vy = 0;
    }
  }
  else
  {
     cam_vy += gravity; 
  }
  
  cam_y -= cam_vy;


  cam_blocky = -(cam_y-MAP_SCALE/2)/MAP_SCALE + 2;

}


U0 DrawIt(CTask *task,CDC *dc)
{
  Physics;
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
  dc->flags|=DCF_TRANSFORMATION;
  dc->transform=&CFTransform;
  // Apply flags and Perspective transform
  dc->x=cx;
  dc->y=cy;
  dc->z=0; // First Person
  dc->color = RED;


  Mat4x4TranslationEqu(dc->r,cam_x,cam_y,cam_z);

  cam_é = (-ms.pos.x/200.0) % ã*2;
  cam_é2 = (ms.pos.y/100.0) % ã*2;
  Mat4x4RotY(dc->r,cam_é);

  Mat4x4RotX(dc->r,cam_é2+ã/2);
  //DCMat4x4Set(dc,dc->r);

  
  
  //Mat4x4TranslationEqu(dc->r,0,0,0);
  //DCMat4x4Set(dc,dc->r);

  
  // Paint screen White
  DCFill(dc,WHITE);

  // 'Cam' Cube
  //draw_cube(dc,-cam_x,-cam_y,-cam_z,0);
  // Draw elems With Global pos Offsets
  
  I64 x,y,z;
  for(z=0;z<MAP_Z;z++){
  for(y=0;y<MAP_Y;y++){
  for(x=0;x<MAP_X;x++){
    U8 elem = mapgrid[(z*MAP_X*MAP_Y)+(y*MAP_X)+x];
    I64 neighboors = 0xFFF;
    if(x>0&&mapgrid[((z)*MAP_X*MAP_Y)+((y)*MAP_X)+(x-1)]>0) neighboors &= 0xFFC;
    if(x<MAP_X-1&&mapgrid[((z)*MAP_X*MAP_Y)+((y)*MAP_X)+(x+1)]>0) neighboors &= 0xFF3;
   
    if(y>0&&mapgrid[((z)*MAP_X*MAP_Y)+((y-1)*MAP_X)+(x)]>0) neighboors &= 0xFCF;
    if(y<MAP_Y-1&&mapgrid[((z)*MAP_X*MAP_Y)+((y+1)*MAP_X)+(x)]>0) neighboors &= 0xF3F;
   
    if(z>0&&mapgrid[((z-1)*MAP_X*MAP_Y)+((y)*MAP_X)+(x)]>0) neighboors &= 0xCFF;
    if(z<MAP_Z-1&&mapgrid[((z+1)*MAP_X*MAP_Y)+((y)*MAP_X)+(x)]>0) neighboors &= 0x3FF;
   
//    if(cam_blockx == x && cam_blocky == y && cam_blockz == z)
//    {
//      elem = UNK1;
//      neighboors = 0xFFF;
//    }
    
    if(elem>=1 && elem<(CUBE_TYPES/6) && neighboors != 0)
    {
      I64 tx = x*MAP_SCALE,
      ty = y*MAP_SCALE,
      tz = z*MAP_SCALE;
      draw_cube(dc,tx,ty,tz,elem,neighboors);
    }
  }
  }
  }

}


U0 Init()
{

  DocClear;
  "$$BG,BLACK$$%h*c",TEXT_ROWS/2,'\n';
  cam_x=-CAM_START_X*MAP_SCALE;
  cam_y=-CAM_START_Y*MAP_SCALE;
  cam_z=-CAM_START_Z*MAP_SCALE;

  cam_blockx = -(cam_x-MAP_SCALE/2)/MAP_SCALE;
  cam_blocky = -(cam_y-MAP_SCALE/2)/MAP_SCALE + 2;
  cam_blockz = -(cam_z-MAP_SCALE/2)/MAP_SCALE;

  cam_é=0;
  cam_é2=0;
  
  // CAlloc Sets mem to 0 also.
  Free(mapgrid);
  U8 *rdnStr = "sfk;sjdkghe2#@33t24gsssdfsf3";
  mapgrid=CAlloc(MAP_X*MAP_Y*MAP_Z*sizeof(U8));
  I64 x,y,z,i;
  for(x=0;x<MAP_X;x++)
  for(z=0;z<MAP_Z;z++)
  {
  {
    U8 rdn = rdnStr[i%StrLen(rdnStr)]%6+6;
    U8 t =UNK1;
    if(x == 4 && z == 4) rdn = 6;    
    //rdn = 0;
    for(y=MAP_Y-1;y>rdn&&y>=0;y--)
    {
      if( y == MAP_Y-1){t=BEDROCK;}
      else if(y == rdn+1) {t = GRASS;}
      else if(y >= rdn+2 && y<= rdn+3){ t = DIRT;}
      else {t = STONE;}

      mapgrid[z*MAP_Y*MAP_X + y*MAP_X + x] = t;
    }
    i++;
  }
  }

  mapgrid[4*MAP_Y*MAP_X + 6*MAP_X + 4] = WOOD;  
  mapgrid[4*MAP_Y*MAP_X + 5*MAP_X + 4] = WOOD;
  mapgrid[4*MAP_Y*MAP_X + 4*MAP_X + 4] = WOOD;
  mapgrid[4*MAP_Y*MAP_X + 3*MAP_X + 4] = WOOD;
  mapgrid[4*MAP_Y*MAP_X + 2*MAP_X + 4] = WOOD;
  mapgrid[4*MAP_Y*MAP_X + 1*MAP_X + 4] = WOOD;
  mapgrid[4*MAP_Y*MAP_X + 0*MAP_X + 4] = LEAVES;
  

  mapgrid[3*MAP_Y*MAP_X + 1*MAP_X + 4] = LEAVES;
  mapgrid[3*MAP_Y*MAP_X + 2*MAP_X + 4] = LEAVES;
  mapgrid[3*MAP_Y*MAP_X + 3*MAP_X + 4] = LEAVES;

  mapgrid[4*MAP_Y*MAP_X + 1*MAP_X + 3] = LEAVES;
  mapgrid[4*MAP_Y*MAP_X + 2*MAP_X + 3] = LEAVES;
  mapgrid[4*MAP_Y*MAP_X + 3*MAP_X + 3] = LEAVES;

  mapgrid[4*MAP_Y*MAP_X + 1*MAP_X + 5] = LEAVES;
  mapgrid[4*MAP_Y*MAP_X + 2*MAP_X + 5] = LEAVES;
  mapgrid[4*MAP_Y*MAP_X + 3*MAP_X + 5] = LEAVES;

  mapgrid[5*MAP_Y*MAP_X + 1*MAP_X + 4] = LEAVES;
  mapgrid[5*MAP_Y*MAP_X + 2*MAP_X + 4] = LEAVES;
  mapgrid[5*MAP_Y*MAP_X + 3*MAP_X + 4] = LEAVES;
 
  
/*/############### CUBE MESH ###################
       6*-----7*             Upside Down! For some reason Y is inverted
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
 0*-----1*/

  I64 cw = MAP_SCALE/2;
  fillArrayI32(verts3D,
  -cw,-cw,-cw, //0
   cw,-cw,-cw, //1
  -cw, cw,-cw, //2
   cw, cw,-cw, //3
  -cw,-cw, cw, //4
   cw,-cw, cw, //5
  -cw, cw, cw, //6
   cw, cw, cw  //7
  );

  fillArrayI32(tris3D,

  2,6,4, 2,4,0,  // -X
  1,7,3, 1,5,7,  // +X
  0,4,1, 1,4,5,  // -Y Top
  2,3,6, 3,7,6,  // +Y Bottom
  0,1,2, 2,1,3,  // -Z
  4,6,7, 4,7,5   // +Z
  );
  /*
  #define BLACK			0
  #define BLUE			1
  #define GREEN			2
  #define CYAN			3
  #define RED			4  
  #define PURPLE		5
  #define BROWN			6
  #define LTGRAY		7

  #define DKGRAY		8
  #define LTBLUE		9
  #define LTGREEN		10
  #define LTCYAN		11
  #define LTRED			12
  #define LTPURPLE		13
  #define YELLOW		14
  #define WHITE			15 
 */
  fillArrayU8(cubesColors,
  1,2,3,4,5,6, // 0 INVALID AIR
  6,6,2,6,6,6, // 1 GRASS
  6,6,6,6,6,6, // 2 DIRT
  8,8,8,8,8,8, // 3 STONE
  0,0,0,0,0,0, // 4 BEDROCK
  7,7,14,14,7,7, // 5 WOOD
  9,9,1,1,9,9, // 6 WATER
  12,12,2,2,12,12, // 7 LAVA
  15,15,15,7,15,15, // 8 SNOW
  10,2,10,2,10,2,  // 9 LEAVES
  5,5,5,5,5,5  // 10 
 );


}

U0 CleanUp()
{
  Free(mapgrid);
  mapgrid = NULL;
}

U0 MoveCamera(I64 x,I64 y,I64 z)
{
  x *= 5;
  y *= 5;
  z *= 5;
  cam_x -= x*Cos(cam_é)-z*Sin(cam_é);
  cam_y -= y;
  cam_z -= x*Sin(cam_é)+z*Cos(cam_é);

  cam_blockx = -(cam_x-MAP_SCALE/2)/MAP_SCALE;
  cam_blocky = -(cam_y-MAP_SCALE/2)/MAP_SCALE + 2;
  cam_blockz = -(cam_z-MAP_SCALE/2)/MAP_SCALE;
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
          cam_vy = -18;
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
        case 'd':
	    
          MoveCamera(1,0,0);
        break;
        case 'a':
   
          MoveCamera(-1,0,0);
        break;
        case 'w':
	    
          MoveCamera(0,0,1);
        break;
        case 's':
	    
          MoveCamera(0,0,-1);
        break;

      }
      //Physics;
    }
  fs_done:
  } catch
  PutExcept;
 
  DocClear;
  SettingsPop;
  CleanUp;
  MenuPop;
  
}

MainLoop;
