function Pandoc(doc)
  quarto.doc.addHtmlDependency({
    name = "nutshell",
    version = "1.0.6",
    scripts = {"nutshell.js"}
  })
end
