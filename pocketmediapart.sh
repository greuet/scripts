#!/bin/bash

output=""

authenticate () {
    printf "Authenticating on Mediapart..."
    if [[ ! -f /tmp/cookies_mdpt.txt ]]
    then
        wget --save-cookies /tmp/cookies_mdpt.txt --keep-session-cookies --delete-after \
             --quiet \
             --post-data 'name=myemail%40host.com&password=XXXXXXXXXX' \
             https://www.mediapart.fr/login_check
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
    output=$(echo "$1" | sed "s#https://www.mediapart.fr/journal/[a-z]*/[0-9]*/\([a-z0-9\-]*\).*#\1#")
    wget --quiet --load-cookies /tmp/cookies_mdpt.txt -q "$1" -O "${output}_tmp"
}

parse_page () {
  # html header
  echo "<!doctype html>"
  echo ""
  echo "<html lang=\"fr\">"
  echo "  <head>"
  echo "    <meta charset=\"utf-8\">"
  echo "    <title>Pocket Mdpt</title>"
  echo "    <meta name=\"description\" content=\"Clean Mdpt article\">"

  # Author
  grep "<meta name=\"author\"" "$1" | \
      sed "s/.*<meta name=\"author\" content=\"\(.*\)\" \/>/    <meta name=\"author\" content=\"\1\">/"

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

  # Navigation
  # echo ""
  # echo "    <nav>"
  # echo "      <ul>"
  # echo "        <li>"
  # echo "          <a href=\"/\">Home</a>"
  # echo "        </li>"
  # echo "        <li>"
  # echo "          <a href=\"memos\">Mémos</a>"
  # echo "        </li>"
  # echo "        <li>"
  # echo "          <a href=\"encrypt\">Chiffrement</a>"
  # echo "        </li>"
  # echo "        <li>"
  # echo "          <a href=\"dactylotest\">Dactylotest</a>"
  # echo "        </li>"
  # echo "      </ul>"
  # echo "    </nav>"

  # article
  echo ""
  echo "    <main>"
  echo "      <article>"

  # article heading
  grep "<meta property=\"og:title\"" "$1" | \
      sed "s/.*<meta property=\"og:title\" content=\"\(.*\)\" \/>/      <h2>\1<\/h2>/"


  ### for 1-page article
  # sed -n "/<div class=\"page-pane\">/,/<ul class=\"mini-pager\">/p" "$1" | \
  #     head -n -1 | tail -n +2 | \
  #     sed "/<p><div class=\"read-also bullet-list universe-journal\">/,/<\/div>/d" | \
  #     sed "s/^\(.*\)/    \1/"
  # sed -n "/<div class=\"page-pane\">/,/<ul class=\"mini-pager\">/p" "$1" | \
  #     head -n -4 | tail -n +2 | \
  ###

  # remove "Lire aussi"
  sed "/<p>.*<div class=\"read-also bullet-list universe-journal\">/,/<\/div>/d" "$1" | \
  # get only text between page-pane, i.e. just text in each article page
      sed -n "/<div class=\"page-pane\">/,/<\/div><!-- page break -->/p" | \
      sed "s/^\( *\)\([^<]*\)<\/p>/\1<p>\2<\/p>/" | \
  # remove page-pane start and end markup
      sed "s/<div class=\"page-pane\">//" | sed "s/<\/div><!-- page break -->//" | \
  # put images into figure markup
      sed "s/^.* <img src=\"\([^\"]*\)\" alt=\"\([^\"]*\)\" title=.*/<figure><img src=\"\1\" alt=\"\2\"><figcaption>\2<\/figcaption><\/figure>/" | \
      sed "s/^.* <img src=\"\([^\"]*\)\" class=\"preview\" alt=\"\([^\"]*\)\" \/> <\/div>/<figure><img src=\"\1\" alt=\"\2\"><\/figure><p>/" | \
      sed 's/<figure>/<figure>\'$'\n  /' | sed 's/<figcaption>/\'$'\n  <figcaption>/' | \
      sed 's/<\/figure>/\'$'\n<\/figure>/' | sed 's/<\/figure>/<\/figure>\'$'\n/' | \
      sed 's/\( \)*<figure>/\'$'\n<figure>/' | \
  # remove span markups
      sed "s/<span[^>]*>//g" | sed "s/<\/span>//g" | \
  # clean h2 markups
      sed "s/<h2 class='h4'>/<h2>/" | sed "s/<h2><\/h2>//" | \
  # indent paragraph and figure markups
      # sed "s/\(<p>.*\)/        \1/g" | sed "s/\(<figure>.*\)/        \1/g"
      sed "s/\(^.*\)/        \1/g" | \
  # remove double target
      sed "s/target=\"_blank\" target=\"_blank\"/target=\"_blank\"/g" | \
  # remove tweet blocks
      grep -v "<blockquote class=\"twitter-tweet\">" | \
  # add missing <p> to line not starting with some spaces followed with < and ending with </p>
      sed '/^ *</! s/\( *\)\(.*\)<\/p>/\1<p>\2<\/p>/'
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
authenticate

# clean previous files on server
ssh -q bakou.ze.cx "rm /var/www/pocketmdpt/*.html"

# get and parse each url in input file
{
    while read url
    do
        # be sure line is not empty
        if [ -n "$url" ]
        then
            clean_url=$(echo "$url" | sed "s/\([^?]*\)?.*/\1/")
            printf  "\nGetting page %s... " "$clean_url"
            get_page "$clean_url?onglet=full"
            parse_page "${output}_tmp" > "$output.html"
            scp -q "$output.html" bakou:/var/www/pocketmdpt/
            rm "${output}_tmp"
            rm "$output.html"
            printf "done!\n"
        fi
    done
} < "$1"

exit 0
