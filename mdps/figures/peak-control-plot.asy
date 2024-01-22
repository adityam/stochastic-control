 // Copied from the output of the julia code and normalized. 
real[][] evaluation = {
         {1.0, 0.6775892334698654, 0.5570509069631363, 0.6775892334698654, 1.0},
         {0.8308952603861908, 0.5570509069631363, 0.37448800468110005, 0.5570509069631363, 0.8308952603861908},
         {0.7021650087770626, 0.37448800468110005, 0.26214160327677005, 0.37448800468110005, 0.7021650087770626},
         {0.5242832065535401, 0.26214160327677005, 0.07489760093622001, 0.26214160327677005, 0.5242832065535401},
         {0.37448800468110005, 0.07489760093622001, 0.0, 0.07489760093622001, 0.37448800468110005},
};

int[][] dummy = {
 {0, 0, 0, 0, 0},
 {0, 0, 0, 0, 0},
 {0, 0, 0, 0, 0},
 {0, 0, 0, 0, 0},
 {0, 0, 0, 0, 0},
};

real[][] optimal = {
 {1.0, 0.6346516007532956, 0.514752040175769, 0.6346516007532956, 1.0},
 {0.8411801632140615, 0.517263025737602, 0.35153797865662273, 0.517263025737602, 0.8411801632140615},
 {0.7030759573132455, 0.35153797865662273, 0.24105461393596986, 0.35153797865662273, 0.7030759573132455},
 {0.5222849968612681, 0.24105461393596986, 0.08035153797865663, 0.24105461393596986, 0.5222849968612681},
 {0.3214061519146265, 0.08035153797865663, 0.0, 0.08035153797865663, 0.3214061519146265},
};

int[][] policy = {
 {1, 1, 1, 1, 1},
 {1, 1, 0, 1, 1},
 {0, 1, 0, 1, 0},
 {0, 0, 0, 0, 0},
 {0, 0, 0, 0, 0},
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
      draw( (t,data[t-1][s-1],s) -- (t,0,s), C[policy[t-1][s-1]] ) ;
      dot ( (t,data[t-1][s-1],s), C[policy[t-1][s-1]] );
    }

  }

  currentprojection = orthographic(projection, up=Y);

}

draw_MC_distribution(evaluation,dummy);
shipout("peak-control-evaluation.pdf"); 

currentpicture=new picture; 
unitsize(2cm);
draw_MC_distribution(optimal,policy);
shipout("peak-control-optimal.pdf"); 

