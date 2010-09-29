;; Load a local file into the store
(ns info.papyri.map
  (:gen-class)
  (:import (java.io File)
           (java.net URI)
           (org.mulgara.connection Connection ConnectionFactory)
           (org.mulgara.query.operation CreateGraph Deletion)
           (org.mulgara.sparql SparqlInterpreter)))
           
      
(def server (URI/create "rmi://localhost/server1"))
(def graph (URI/create "rmi://localhost/papyri.info#pi"))
           
(defn -main
  [args]
  (let [url (first args)
	deletesub (str "construct { <" url "> ?p ?r }
		    from <rmi://localhost/papyri.info#pi>
		    where { <" url "> ?p ?r }")
	deleteobj (str "construct { ?s ?p <" url ">}
                        from <rmi://localhost/papyri.info#pi>
                        where { ?s ?p <" url ">}")]
	(let [factory (ConnectionFactory.)
	      conn (.newConnection factory server)
	      interpreter (SparqlInterpreter.)]
	  (.execute conn (CreateGraph. graph))
	  (.execute (Deletion. graph, (.parseQuery interpreter deletesub)) conn)
	  (.execute (Deletion. graph, (.parseQuery interpreter deleteobj)) conn)
	  (.close conn))))
          
(-main (rest *command-line-args*))
