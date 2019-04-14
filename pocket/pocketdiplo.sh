#!/bin/bash

authenticate () {
    printf "Authenticating on le Monde Diplomatique..."
    if [[ ! -f /tmp/cookies_diplo.txt ]]
    then
        wget --save-cookies /tmp/cookies_diplo.txt --keep-session-cookies --delete-after \
             --quiet \
             --post-data 'email=myemail%40gmail.com&mot_de_passe=XXXXXXXXXX' \
             "https://lecteurs.mondediplo.net/?page=connexion_sso"
        if [[ $? != 0 ]]
        then
            printf " FAIL\n"
            exit 1
        else
            printf " done\n"
        fi
    else
        printf " already done\n"
    fi
}

get_page () {
    output=$(echo "$1" | sed "s/https:\/\/www.monde-diplomatique.fr\/[0-9]\{4\}\/[0-9]\{2\}\/\(.*\)/\1/g" | sed "s#/#_#g")
    wget --quiet --load-cookies /tmp/cookies_diplo.txt -q "$1" -O "${output}_tmp"
}

parse_page () {
    echo "<!doctype html>"
    echo ""
    echo "<html lang=\"fr\">"
    echo "  <head>"
    echo "    <meta charset=\"utf-8\">"
    echo "    <title>Pocket Diplo</title>"
    echo "    <meta name=\"description\" content=\"Clean Diplo article\">"

    # Author
    grep "article:author" "$1" | \
        sed "s/<meta property=\"article:author\" content=\"\([^\"]*\)\" \/>/    <meta name=\"author\" content=\"\1\">/"

    # Image
    grep "<meta property=\"og:image\"" "$1" | sed "s/\(.*\)/    \1/"

    # html again
    echo "    <link href=\"https://fonts.googleapis.com/css?family=Gentium+Basic\" rel=\"stylesheet\">"
    echo "    <link rel=\"stylesheet\" href=\"../stylehtml5.css\">"
    echo "  </head>"
    echo ""
    echo "  <body>"
    echo ""
    echo "    <header>"


    # Title
    grep "<meta property=\"og:title\"" "$1" | \
        sed "s/.*<meta property=\"og:title\" content=\"\(.*\)\" \/>/      <h1>\1<\/h1>/"
    echo "    </header>"

    # article
    echo ""
    echo "    <main>"
    echo "      <article>"


    # chapo
    grep "<div class=\"crayon article-chapo-[0-9]* chapo\">" "$1" | \
        sed "s/^\t*<div class=\"crayon article-chapo-[0-9]* chapo\">\(.*\)<\/div>/<i>\1<\/i>/g"

    echo "<hr>"


    # article heading
    grep "<meta property=\"og:title\"" "$1" | \
        sed "s/.*<meta property=\"og:title\" content=\"\(.*\)\" \/>/      <h2>\1<\/h2>/"

    # contenu
    sed -n "/<div id=\"conteneur\">/,/<div class=\"lesauteurs\">/p" "$1" | \
        sed -n "/mot-lettrine/,/^\t\t\t$/p" | \
        # images
        sed "s/<img src='local/<img src='https:\/\/www.monde-diplomatique.fr\/local/"

    echo "      </article>"
    echo "    </main>"
    echo ""
    echo "    <footer>"
    echo "      <a href=\"http://validator.w3.org/check?uri=referer\""
    echo "         onclick=\"this.href='http://validator.w3.org/check?uri=' + document.URL\">"
    echo "        <img src=\"../img/valid_html.png\" alt=\"Valid HTML5\">"
    echo "      </a>"
    echo "      <a href=\"http://www.azote.org/\" title=\"Nom de domaine\">"
    echo "        <img src=\"../img/azote_80_15_gris.gif\" alt=\"Nom de domaine\">"
    echo "      </a>"
    echo "      <a href=\"http://jigsaw.w3.org/css-validator/validator?uri=https://bakou.ze.cx/style.css\">"
    echo "        <img src=\"../img/valid_css.gif\" alt=\"Valid CSS!\">"
    echo "      </a>"
    echo "    </footer>"
    echo ""
    echo "  </body>"
    echo "</html>"
}


# check if arguments
if [ $# -eq 0 ]
then
    echo "File containing URLs is expected"
    exit 1
fi

# login
# authenticate

# clean previous files on server
ssh -q bakou.ze.cx "rm /var/www/pocketmdpt/*.html"

# get and parse each url in input file
{
    while read url
    do
        # be sure line is not empty
        if [ -n "$url" ]
        then
            printf  "\nGetting page %s... " "$url"
            # output=$(echo "$url" | sed "s/https:\/\/www.monde-diplomatique.fr\/[0-9]\{4\}\/[0-9]\{2\}\/\(.*\)/\1/g" | sed "s#/#_#g")
            get_page "$url"
            parse_page "${output}_tmp" > "$output.html"
            scp -q "$output.html" bakou:/var/www/pocketmdpt/
            rm "${output}_tmp"
            rm "$output.html"
            printf "done!\n"
        fi
    done
} < "$1"

exit 0