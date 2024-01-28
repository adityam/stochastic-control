 // Copied from the output of the julia code and normalized. 

real[][] optimal = {
{0.7766990291262136, 0.8902912621359225, 0.9271844660194175, 0.9514563106796117, 0.9757281553398058, 1.0},
 {0.6116504854368933, 0.7087378640776699, 0.7669902912621359, 0.7912621359223301, 0.8155339805825242, 0.8398058252427184},
 {0.45145631067961167, 0.5242718446601942, 0.5970873786407767, 0.6359223300970874, 0.6601941747572816, 0.6844660194174758},
 {0.2961165048543689, 0.3446601941747573, 0.3932038834951457, 0.44174757281553395, 0.4902912621359223, 0.5339805825242718},
 {0.14563106796116504, 0.1699029126213592, 0.1941747572815534, 0.21844660194174756, 0.24271844660194172, 0.2669902912621359},
};

int[][] policy = {
 {0, 0, 1, 1, 1, 1},
 {0, 0, 1, 1, 1, 1},
 {0, 0, 0, 1, 1, 1},
 {0, 0, 0, 0, 0, 0},
 {0, 0, 0, 0, 0, 0},
};

settings.outformat = "pdf";
import three;
import labelpath3;
settings.render = 0;

unitsize(2cm);

void draw_MC_distribution(real[][] data, int[][] policy) {
  int T = data.length;
  int S = data[1].length;

  pen[] C = { black, mediumred };

  triple projection = (1.5,1,10);

  draw(O -- (T+0.5)*X, arrow=Arrow3(DefaultHead2), 
             L=Label("time", position=EndPoint));
  draw(O -- 1.2Y, arrow=Arrow3(DefaultHead2));
  draw(O -- (S+1)*Z, arrow=Arrow3(DefaultHead2));

  triple P, Q;

  for(int t = 1; t <= T; ++t) {
    draw( (t,0,0)--(t,0,S+1)--(t,1.2,S+1)--(t,1.2,0)--cycle);

    P = (t+0.1,0,0);
    Q = (t+0.1,0,S+1);
    string txt = "$t = " + string(t) + "$";
    Label L = Label(txt,align=0.0E, p=fontsize(5pt));
    L = rotate(90-degrees(atan2(projection.x, projection.y)),P,Q)*L;

    label(L, P--Q );

    draw( surface((t,0,0)--(t,0,S+1)--(t,1.2,S+1)--(t,1.2,0)--cycle), surfacepen=white, light=nolight );


    for(int s = 1; s <= S; ++s) {
      // FIXME: plot negative 
      draw( (t,data[t-1][s-1],S+1-s) -- (t,0,S+1-s), C[policy[t-1][s-1]] ) ;
      dot ( (t,data[t-1][s-1],S+1-s), C[policy[t-1][s-1]] );
    }

  }

  currentprojection = orthographic(projection, up=Y);

}

draw_MC_distribution(optimal,policy);

