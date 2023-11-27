#!/bin/bash
#
# Get the three databases, and combine if multipart

function getAndCombineFiles {
    # ASN/CITY/COUNTRY is uppercase in the URL (^^ converts to uppercase)
    curl -sL \
        "https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-${1^^}_MMDB.lst" \
        | xargs -n1 curl -sLOJ
    # Check if multipart files exist (.??) and combine if so
    FILES=(GeoLite2-$1.mmdb.??)
    if [ -f ${FILES[0]} ]; then
        cat GeoLite2-$1.mmdb.?? > $1
        rm GeoLite2-$1.mmdb.??
    fi
}

getAndCombineFiles ASN
getAndCombineFiles CITY
getAndCombineFiles COUNTRY
echo Done
