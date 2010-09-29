;; Load a local file into the store
(ns info.papyri.map
  (:gen-class)
  (:import (java.io File)
           (java.net URI)
           (org.mulgara.connection Connection ConnectionFactory)
           (org.mulgara.query.operation CreateGraph Load)))
      
(def server (URI/create "rmi://localhost/server1"))
(def graph (URI/create "rmi://localhost/papyri.info#pi"))
           
(defn -main
  [args]
  (let [factory (ConnectionFactory.)
        conn (.newConnection factory server)
        file (File. (first args))]
      (.execute conn (CreateGraph. graph))
      (.execute (Load. (.toURI file) graph, true) conn)
      (.close conn)))
      
(-main *command-line-args*)
           
         