 // Copied from the output of the julia code and normalized. 

real[][] optimal = {
 {0.17857142857142863, 0.5964285714285716, 0.7321428571428571, 0.8214285714285714, 0.9107142857142857, 1.0},
 {0.10714285714285716, 0.4642857142857144, 0.6785714285714286, 0.7678571428571429, 0.8571428571428572, 0.9464285714285715},
 {0.05357142857142858, 0.3214285714285715, 0.5892857142857144, 0.7321428571428571, 0.8214285714285714, 0.9107142857142857},
 {0.01785714285714286, 0.19642857142857145, 0.37500000000000006, 0.5535714285714286, 0.7321428571428571, 0.8928571428571429},
 {0.0, 0.08928571428571429, 0.17857142857142858, 0.26785714285714285, 0.35714285714285715, 0.44642857142857145},
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

