Development
===========

.. todo:: 
    Complete development guidelines for Whoami

Compiling
---------

Configuration
-------------

Run
---

Continuous Integration and Deployment
-------------------------------------


Branching
---------
We use `trunk based development`_ to achieve rapid development and 
continuous relase of new versions direclty to production. Using only 
the trunk branch to handle releases and avoiding staging changes 
between branches to deploy simplifies CI/CD immensely.

Main
^^^^
Is the current running production version and should always be deployable.

Feature branches
^^^^^^^^^^^^^^^^
- Feature branches get its own docker tag with the same name when pushing 
- to DockerHub. Each commit get a tag with the commit timestamp and 
  commit-shorthash. 
- Latest tag is only updated when pushing the master branch.

.. _`trunk based development`: https://trunkbaseddevelopment.com/
