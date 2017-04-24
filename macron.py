#!/usr/bin/env python
# -*- coding: utf-8 -*-
import random

nbWords = 8

listWords = \
["projet","rassembler","avancer","réconcilier","mutation","réel","ambition",
"renouvellement","progressiste","égalitarisme","partenariat",
"esprit d'initiative","innovation","pénibilité","souplesse",
"libérer le travail","je n'ai pas peur de le dire","je veux être clair",
"modernité","charte","droits et devoirs","responsabilité","combat",
 "pardon de vous le dire","efficace","digital","cluster","progrès",
 "progressiste","anti-système"]

selectedIndices = []

for word in random.sample(listWords, nbWords):
    print " ", word
