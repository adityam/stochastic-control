MathJax.Hub.Config({
  "HTML-CSS": { 
      fonts: ["TeX"]
  }, 
tex2jax: {
  inlineMath: [ ['$','$'], ["\\(","\\)"] ],
  displayMath: [ ['$$','$$'], ["\\[","\\]"] ],
  processEscapes: true,
},
  TeX : {
      equationNumbers : { autoNumber: "AMS" }, 
      Macros : {
        PR: "\\mathbb{P}",
        EXP: "\\mathbb{E}",
        IND: "\\mathbb{I}",
        reals: "\\mathbb{R}",
        integers: "\\mathbb{Z}",
        TRANS: "\\intercal",
        VEC: "\\operatorname{vec}",
        TR:  "\\operatorname{Tr}",
        // mathcal: "\\mathscr",
        ALPHABET: ["\\mathcal{#1}", 1],
        MATRIX: ["\\begin{bmatrix} #1 \\end{bmatrix}", 1],
        NORM: ["\\left\\lVert #1 \\right\\rVert", 1],
        ABS: ["\\left\\lvert #1 \\right\\rvert", 1],
      }
  }
});

MathJax.Hub.processSectionDelay=0; 

MathJax.Ajax.loadComplete("https://adityam.github.io/stochastic-control/js/mathjax-local.js")
