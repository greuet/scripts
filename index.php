<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>#pouetcommeMacron</title>
    <link href="macron.css" rel="stylesheet" type="text/css" />
</head>
<body>

  <div id="nav">
    <h1>Le tirage</h1>
    Et le tirage est :
    <ul>
    <?php
       $nbWords = 8;
       $listWords =
       array("avancer","réconcilier","mutation","réel",
       "ambition","renouvellement","progressiste","égalitarisme","partenariat",
       "esprit d'initiative","innovation","pénibilité","souplesse", "libérer le
       travail","je n'ai pas peur de le dire","je veux être clair","modernité",
       "charte","droits et devoirs","responsabilité","combat",
       "pardon de vous le dire","efficace","digital","cluster");

       $selectedIndices = array_rand($listWords,$nbWords);

       echo "<li>projet</li>"; // projet is always selected :)
       for ($i = 0; $i < sizeof($selectedIndices); $i++)
           echo "<li>" . $listWords[$selectedIndices[$i]] . "</li>";
       ?>
    </ul>

    <a href = ".">Nouveau tirage</a>

    <h1>#pouetcommeMacron</h1> Le but du jeu est d'écrire un discours qui sonne
    comme ceux d'Emmanuel Macron en utilisant le tirage précédent. Ce tirage
    donne :
    <ul>
      <li>des mots qui ne veulent rien dire mais qui donnent l'impression de
      dire quelque chose</li>
      <li>des tics de langage ou phrases de liaison passe-partout</li>
      <li>le tout tiré au hasard parmi une liste de mots/phrases qu'on retrouve
      souvent dans les discours de Macron</li>
    </ul>

    <p>C'est rigolo parce que c'est super facile de construire un discours comme
  ça. Et après tu pouet ton discours et comme ça tout le monde se rend compte
  que la plupart des discours c'est du vent.</p>

    <p>C'est inspiré de Franck
    Lepage : <a href="https://youtu.be/a7ZYIUkzoqQ">youtu.be/a7ZYIUkzoqQ</a>.
    </p>

    <p>Si tu veux améliorer le générateur, il y a le php, le css et un script
      qui fait la même chose en python ici :
      <a href="https://github.com/greuet/scripts">
        https://github.com/greuet/scripts</a>.
    </p>



    <h1>Exemple</h1> Je viens de tirer les mots « projet », « libérer le
    travail », « Je n'ai pas peur de le dire », « numérique », « souplesse »,
    « droits et des devoirs », « avancer », « rassembler », « progressiste ». Et
    ça peut donner :

    <p>Eh bien moi, le « projet » que je propose de mener, c'est de « libérer le
    travail ». « Je n'ai pas peur de le dire », à l'ère du « numérique », nous
    pouvons et nous devons aller vers plus de « souplesse ». Nous avons des
    « droits et des devoirs » : en particulier, le droit d'« avancer » et le
    devoir de « rassembler ». Et cela, nous le ferons ensemble, de manière
    « progressiste ».</p>

  </div>

</body>
</html>
