(ns info.papyri.indexer
  (:use clojure.contrib.math)
  (:import 
    (com.hp.hpl.jena.rdf.model Model ModelFactory Resource ResourceFactory)
    (java.io File FileInputStream FileOutputStream FileReader StringWriter)
    (java.net URI URL URLEncoder URLDecoder)
    (java.nio.charset Charset)
    (java.text Normalizer Normalizer$Form)
    (java.util ArrayList TreeMap)
    (java.util.concurrent Executors ConcurrentLinkedQueue)
    (javax.xml.parsers SAXParserFactory)
    (javax.xml.transform Result )
    (javax.xml.transform.sax SAXResult)
    (javax.xml.transform.stream StreamSource StreamResult)
    (net.sf.saxon Configuration FeatureKeys PreparedStylesheet StandardErrorListener StandardURIResolver TransformerFactoryImpl)
    (net.sf.saxon.trans CompilerInfo XPathException)
    (org.apache.solr.client.solrj SolrServer)
    (org.apache.solr.client.solrj.impl CommonsHttpSolrServer StreamingUpdateSolrServer BinaryRequestWriter)
    (org.apache.solr.client.solrj.request RequestWriter)
    (org.apache.solr.common SolrInputDocument)
    (org.mulgara.connection Connection ConnectionFactory)
    (org.mulgara.query ConstructQuery Query)
    (org.mulgara.query.operation Command CreateGraph)
    (org.mulgara.sparql SparqlInterpreter)
    (org.xml.sax InputSource)
    (org.xml.sax.helpers DefaultHandler)))
      
(def filepath "/data/papyri.info/idp.data")
(def xsltpath "/data/papyri.info/svn/pn/pn-xslt")
(def htpath "/data/papyri.info/pn/idp.html")
(def solrurl "http://localhost:8983/solr/")
(def numbersurl "http://localhost:8090/sparql?query=")
(def server (URI/create "rmi://localhost/server1"))
(def graph (URI/create "rmi://localhost/atlantides#biblio"))
(def nthreads 10)
(def nserver "http://dev.papyri.info")
(def conn (.newConnection (ConnectionFactory.) server))
(def citations (ref (ConcurrentLinkedQueue.)))
(def documents (ref (ConcurrentLinkedQueue.)))



(defn init-templates
  "Initialize XSLT template pool."
    [xslt, nthreads, pool]
  (dosync (ref-set (load-string pool) (ConcurrentLinkedQueue.) ))
  (dotimes [n nthreads]
    (let [xsl-src (StreamSource. (FileInputStream. xslt))
            configuration (Configuration.)
            compiler-info (CompilerInfo.)]
          (doto xsl-src 
            (.setSystemId xslt))
	  (doto configuration
	    (.setXIncludeAware true))
          (doto compiler-info
            (.setErrorListener (StandardErrorListener.))
            (.setURIResolver (StandardURIResolver. configuration)))
          (dosync (.add (load-string (str "@" pool)) (PreparedStylesheet/compile xsl-src configuration compiler-info))))))
            
(defn substring-after
  [string1 string2]
  (.substring string1 (if (.contains string1 string2) (+ (.indexOf string1 string2) (.length string2)) (.length string2))))

(defn substring-before
  [string1 string2]
  (.substring string1 0 (if (.contains string1 string2) (.indexOf string1 string2) 0)))



          


(defn transform
  "Takes an java.io.InputStream, a list of key/value parameter pairs, and a javax.xml.transform.Result"
  [url, params, #^Result out, pool]
    (let [xslt (.poll pool)
        transformer (.newTransformer xslt)]
      (when (not (== 0 (count params)))
        (doseq [param params] (doto transformer
          (.setParameter (first param) (second param)))))
      (.transform transformer (StreamSource. (.openStream (URL. url))) out)
      (.add pool xslt)))
    
(defn has-part-query
  [url]
  (format  "prefix dc: <http://purl.org/dc/terms/> 
            construct {<%s> dc:relation ?a}
            from <rmi://localhost/papyri.info#pi>
            where { <%s> dc:hasPart ?a }" url url))

(defn citation-query
  []
  (format  "prefix dc: <http://purl.org/dc/terms/> 
            construct {?a dc:bibliographicCitation ?b}
            from <rmi://localhost/papyri.info#pi>
            where { ?a dc:bibliographicCitation ?b }"))
            
(defn relation-query
  [url]
  (format  "prefix dc: <http://purl.org/dc/terms/> 
            construct {?a dc:relation ?b}
            from <rmi://localhost/papyri.info#pi>
            where { <%s> dc:hasPart ?a .
                    ?a dc:relation ?b}" url))

(defn replaces-query
  [url]
  (format  "prefix dc: <http://purl.org/dc/terms/> 
            construct {?a dc:replaces ?b}
            from <rmi://localhost/papyri.info#pi>
            where { <%s> dc:hasPart ?a .
                    ?a dc:replaces ?b }" url))

(defn is-replaced-by-query
  [url]
  (format  "prefix dc: <http://purl.org/dc/terms/> 
            construct {?a dc:isReplacedBy ?b}
            from <rmi://localhost/papyri.info#pi>
            where { <%s> dc:hasPart ?a .
                    ?a dc:isReplacedBy ?b }" url))
                    
(defn execute-query
  [query]
  (let [interpreter (SparqlInterpreter.)]
    (.execute (.parseQuery interpreter query) conn)))

(defn get-model
  [answer]
  (let [model (ModelFactory/createDefaultModel)]
    (while (.next answer)
      (doto model
	(.add (ResourceFactory/createStatement
	       (ResourceFactory/createResource (.toString (.getObject answer 0)))
	       (ResourceFactory/createProperty (.toString (.getObject answer 1)))
	       (ResourceFactory/createResource (.toString (.getObject answer 2)))))))
    model))

(defn answer-seq
  [answer]
  (when (.next answer)
    (cons (list (.getObject answer 0) (.getObject answer 1) (.getObject answer 2)) (answer-seq answer))))
            

                  


(defn queue-citations []
  (let [items (execute-query (citation-query))]
    (when (.next items)
      (.add @citations (list (.getObject items 0) (.getObject items 2))))))

(defn index-solr
  []
  (.start (Thread. 
	   (fn []
	     (let [solr (StreamingUpdateSolrServer. solrurl 5000 5)]
	       (.setRequestWriter solr (BinaryRequestWriter.))
	       (while (= (count @documents) 0)
		 (Thread/sleep 30000))
	       (when (> (count @documents) 0)
		 (let [docs (ArrayList.)]
		   (.addAll docs @documents)
		   (.removeAll @documents docs)
		   (.add solr docs))))
	       (Thread/sleep 30000)
	       (when (> (count @documents) 0)
		 (index-solr))))))

(defn -main [& args]

  ;; Start Solr indexing thread
  (index-solr)

  ;; queue up citations for indexing
  (queue-citations)
  
  ;; Index docs queued in @citations
   (let [pool (Executors/newFixedThreadPool nthreads)
        tasks
	(map (fn [x]
	       (fn []
		 (let [solrdoc (SolrInputDocument.)]
		   (.addField solrdoc "identifier" (first x))
		   (.addField solrdoc "citation" (last x))
		   (.add @documents solrdoc)))) @citations)]
	     (doseq [future (.invokeAll pool tasks)]
	       (.get future))
	     (doto pool
	       (.shutdown)))
  (when (> (count @documents) 0)
    (index-solr))

  (let [solr (CommonsHttpSolrServer. solrurl)]
    (doto solr 
      (.commit)
      (.optimize))))

  
(-main)
