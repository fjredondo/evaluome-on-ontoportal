from rdflib import Graph
from rdflib.namespace import RDF
from rdflib import Namespace
from rdflib import URIRef

owl = Namespace("http://www.w3.org/2002/07/owl#")

# file = './data.ecoportal.lifewatch.eu/bco__huron.ttl'

ontology = owl.Ontology

# g = Graph()
# g.parse(file)

# print(len(g))

import os
import sys

# Comprobación de seguridad, ejecutar sólo si se recibe 1 argumento real
if len(sys.argv) == 2:
    initPath = sys.argv[1]
#    print(initPath)
else:
    initPath = "."


for current_dir_path, current_subdirs, current_files in os.walk(initPath):
	for aFile in current_files:
		if aFile.endswith(".ttl") :
			ttl_file_path = str(os.path.join(current_dir_path, aFile))
			file_name = os.path.basename(ttl_file_path )
			folder_path = os.path.dirname(ttl_file_path )
			path = folder_path.rstrip(os.sep)
			ttl_folder = os.path.basename(path)
			g = Graph()
			g.parse(ttl_file_path)
			# find all subjects (s) of type (rdf:type) ontology (owl:Ontology)
			for s, p, o in g.triples((None, RDF.type, ontology)):
				print(f"{ttl_folder},{file_name},{s}")
