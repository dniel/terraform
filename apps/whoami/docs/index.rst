Welcome to Whoami's documentation!
=================================================

.. note::
    *This is some important information about Whoami.*    

Whoami is a debugging webserver written by the people behind `Traefik`_, 
The Cloud Native Edge Router, and is a very helpful tool to debug
routing and configuration of `Kubernetes`_ ingress routing rules.

.. caution::
    *This is a warning for some reason.*


.. kroki::
   :caption: Diagram
   :type: plantuml

    @startuml
    Alice -> Bob: Authentication Request
    Bob --> Alice: Authentication Response

    Alice -> Bob: Another authentication Request
    Alice <-- Bob: Another authentication Response
    @enduml


Features
--------

.. todo:: 
    complete feature list

-  Configure return codes from whoami to test error handling and stuff.
-  API mode to return structured JSON data from endpoints.
-  ++


.. toctree::
   :caption: Table of Contents
   :name: mastertoc
   :titlesonly:
   :glob:

   start/*
   examples/*
   dev/*

.. _Traefik: https://containo.us/traefik/
.. _Kubernetes: https://kubernetes.org/
