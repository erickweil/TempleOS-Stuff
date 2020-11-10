
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

  I32 tris3D[48];
  fillArray(tris3D,
  YELLOW,0,1,2, YELLOW,2,1,3,
  BROWN,2,6,4,  BROWN,2,4,0,
  GREEN,0,4,1,  GREEN,1,4,5,
  RED,1,7,3,  RED,1,5,7,
  CYAN,4,6,7,  CYAN,4,7,5,
  BLUE,2,3,6,  BLUE,3,7,6);

// Global Vars
  CDC *dc= NULL;

  CD3I32 tri[3];

  I64 W = 0;
  I64 H = 0;
  I64 W2 =0;
  I64 H2 =0;

  // WTFis this
  F64 é=0,è=0,ê=0;
  I64 man_xx,man_yy;

#define SCRN_SCALE		512
#define MAN_HEIGHT		125


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



U0 draw_cube(I64 Px,I64 Py,I64 Pz)
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

U0 Main()
{
  WinMax;
  WinBorder;
  //  public class CD3I32 //Three dimensional I32 pt
  //  {
  //    I32	x,y,z;
  //  };


  // four vertices, a Quad
  //CD3I32 poly[4];

  // Canvas
  dc=DCAlias;
  // Alloc canvas
  DCDepthBufAlloc(dc);
  // WTF
  dc->flags|=DCF_TRANSFORMATION;
  // No problems, Exceptions come to me
  // Maybe because the Free thing below?
  try {
    W = Fs->pix_width;
    H = Fs->pix_height;
    W2 = W/2;
    H2 = H/2;

    // Repeat until a char is typed
    while (!ScanChar) {
      // //Reset device context depth buf to far away.
      DCDepthBufRst(dc);
      // WTF Symmetry?
      //DCSymmetrySet(dc,W2,H2,
      //   ms.pos.x-Fs->pix_left-Fs->scroll_x,
      //   ms.pos.y-Fs->pix_top-Fs->scroll_y);
      // Set color...
      dc->color=LTBLUE;
      // Line between center and mouse
      GrLine(dc,W2,H2,
	    ms.pos.x-Fs->pix_left-Fs->scroll_x,
	    ms.pos.y-Fs->pix_top-Fs->scroll_y);
      // Matrix transformations...
      // Maybe that cause the rotation
/*  I64 man_é = é;

  I64 *s2w,xh,yh,zh;
  //World to scrn
  Mat4x4RotZ(dc->r,man_é+ã/2);
  Mat4x4RotX(dc->r,ã/2);
  DCMat4x4Set(dc,dc->r);

  xh=-man_xx/SCRN_SCALE; yh=-man_yy/SCRN_SCALE; zh=0;
  Mat4x4MulXYZ(dc->r,&xh,&yh,&zh);
  Mat4x4TranslationEqu(dc->r,xh,yh,zh);

  //Scrn to world
  s2w=Mat4x4IdentNew();
  Mat4x4RotX(s2w,-ã/2);
  Mat4x4RotZ(s2w,-man_é-ã/2);
  xh=0; yh=0; zh=SCRN_SCALE;
  Mat4x4MulXYZ(s2w,&xh,&yh,&zh);
*/
//      Mat4x4IdentEqu(dc->r);
//      Mat4x4RotX(dc->r,ê);
//      Mat4x4RotY(dc->r,è);
//      Mat4x4RotZ(dc->r,é);
//      DCMat4x4Set(dc,dc->r);
      man_xx = ms.pos.x-Fs->pix_left-Fs->scroll_x -W2;
      man_yy = ms.pos.y-Fs->pix_top-Fs->scroll_y -H2;

      Mat4x4TranslationEqu(dc->r,man_xx,man_yy,150);

      dc->transform=&CFTransform;

      dc->x=W2;
      dc->y=H2;
      dc->z=500;

      dc->color=GREEN;
      //dc->transform=&DCTransform;
  
      //GrLine(dc,
      //draw_cube(ms.pos.x-Fs->pix_left-Fs->scroll_x,
      //          ms.pos.y-Fs->pix_top-Fs->scroll_y, 
      //          0
      //);
      
      draw_cube(-100,-100,-100);
      draw_cube(-100,100,-100);
      draw_cube(100,-100,-100);
      draw_cube(100,100,-100);
      
      draw_cube(-100,-100,100);
      draw_cube(-100,100,100);
      draw_cube(100,-100,100);
      draw_cube(100,100,100);
      

      // Wait a screen refresh
      Refresh;
      // Paint Background
      //DCFill; 
      DCFill(dc,WHITE);
      //DCClear; // Paint black Screen!!
      // Make everything rotate...
      é+=2.1*ã/180.0;
      è+=1.1*ã/180.0;
      ê+=0.5*ã/180.0;
      //break;
    }
  } catch
    PutExcept;

  DCFill;
  // Free Canvas
  DCDel(dc);
}

Main;
