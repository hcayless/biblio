;; Load a local file into the store
(ns info.papyri.map
  (:gen-class)
  (:import (java.io File)
           (java.net URI)
           (org.mulgara.connection Connection ConnectionFactory)
           (org.mulgara.query.operation DropGraph)
           (org.mulgara.sparql SparqlInterpreter)))
           
      
(def server (URI/create "rmi://localhost/server1"))
(def graph (URI/create "rmi://localhost/papyri.info#pi"))
           
(defn -main
  [args]
  (let [factory (ConnectionFactory.)
        conn (.newConnection factory server)
        interpreter (SparqlInterpreter.)]
      (.execute conn (DropGraph. graph))
      (.close conn)))
      
(-main (rest *command-line-args*))
