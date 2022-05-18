module drawviewer

/*
typedef struct {
         float x, y;
  } point;

  typedef struct {
        point P[4];
  } Bezier;

  /* Variables globales */
  Bezier Global_Bezier;
  int level=1;

void DrawLine(int x1, int y1, int x2, int y2,float r, float v, float b)
  {
    glColor3f(r,v,b);
    glBegin(GL_LINES);
    glVertex2i(x1,y1);
    glVertex2i(x2,y2);
    glEnd();
    glFlush();
  }

  void DrawBezierBase(Bezier p,float r,float v,float b)
  {
    DrawLine(p.P[0].x,p.P[0].y,p.P[1].x,p.P[1].y,r,v,b);
    DrawLine(p.P[1].x,p.P[1].y,p.P[2].x,p.P[2].y,r,v,b);
    DrawLine(p.P[2].x,p.P[2].y,p.P[3].x,p.P[3].y,r,v,b);
  }

  void DrawBezierRecursive (Bezier b, int level)
  {
          if (level <= 0) {
  	  /* draw a line segment */
                DrawLine((int) (b.P[0].x + 0.5), (int) (b.P[0].y + 0.5),
                                (int) (b.P[3].x + 0.5), (int) (b.P[3].y + 0.5),1,1,1);
          } else {
                  Bezier left, right;
                  /* subdivide into 2 Bezier segments */
                  left.P[0].x = b.P[0].x;
                  left.P[0].y = b.P[0].y;
                  left.P[1].x = (b.P[0].x + b.P[1].x) / 2;
                  left.P[1].y = (b.P[0].y + b.P[1].y) / 2;
                  left.P[2].x = (b.P[0].x + 2*b.P[1].x + b.P[2].x) / 4;
                  left.P[2].y = (b.P[0].y + 2*b.P[1].y + b.P[2].y) / 4;
                  left.P[3].x = (b.P[0].x + 3*b.P[1].x + 3*b.P[2].x + b.P[3].x) / 8;
                  left.P[3].y = (b.P[0].y + 3*b.P[1].y + 3*b.P[2].y + b.P[3].y) / 8;
                  DrawBezierBase(left,0,1,0);
                  right.P[0].x = left.P[3].x;
                  right.P[0].y = left.P[3].y;
                  right.P[1].x = (b.P[1].x + 2*b.P[2].x + b.P[3].x) / 4;
                  right.P[1].y = (b.P[1].y + 2*b.P[2].y + b.P[3].y) / 4;
                  right.P[2].x = (b.P[2].x + b.P[3].x) / 2;
                  right.P[2].y = (b.P[2].y + b.P[3].y) / 2;
                  right.P[3].x = b.P[3].x;
                  right.P[3].y = b.P[3].y;
                  DrawBezierBase(right,0,0,1);
                  /* draw the 2 segments recursively */
                  DrawBezierRecursive (left, level -1);
                  DrawBezierRecursive (right, level -1);
          }
  }

  void DrawBezier()
  {
        DrawBezierBase(Global_Bezier,1,0,0);
        DrawBezierRecursive(Global_Bezier,level);
  }
*/
