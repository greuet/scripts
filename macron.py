#!/usr/bin/env python
# -*- coding: utf-8 -*-
from random import randint

nbWords = 8

listWords =
["projet","rassembler","avancer","réconcilier","mutation","réel","ambition",
"renouvellement","progressiste","égalitarisme","partenariat",
"esprit d'initiative","innovation","pénibilité","souplesse",
"libérer le travail","je n'ai pas peur de le dire","je veux être clair",
"modernité","charte","droits et devoirs","numérique","responsabilité","combat",
"pardon de vous le dire","efficace"]

selectedIndices = [randint(0,len(listWords)-1)]
i = 0
while i < nbWords:
    randIndex = randint(0,len(listWords)-1)
    if (randIndex not in selectedIndices):
        selectedIndices.append(randIndex)
        i = i+1

for index in selectedIndices:
    print listWords[index]
