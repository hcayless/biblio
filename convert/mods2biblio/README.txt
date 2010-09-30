REAMDME

mods2bibo.xsl

This XSL 2.0 transform has been used to convert MODS records held by the Pleiades project to RDF n3 according to the bibo ontology use conventions adopted by the ISAW digital projects team. It has also been used to successfully convert MODS records exported from Zotero.

Parameters:

* noidurl: the first part of the URL to use for constructing noids (default: http://biblio.atlantides.org/item/)

* noidpfx: the first letter to use in the noid item value (default: "p" for pleiades)

Note that noids are calculated by taking the $noidurl then postfixing the $noidpfx then postfixing an integer which is calculated based on the document order of the <mods> element being processed. So, using defaults, the fifth mods element in a file would produce: http://biblio.atlantides.org/item/p5
   