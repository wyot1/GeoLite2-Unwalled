#!/usr/bin/env bash

set -euo pipefail

split_files() {
  original_dir="$(pwd)"
  for dir in "${@}"; do
    cd "${dir}"
    while read -r file; do
      size=$(stat --printf="%s" "${file}")
      if ((size > MAX_SIZE)); then
        echo >&2 "File ${file} is too large, splitting"
        split -b "${MAX_SIZE}" -d "${file}" "${file}."
        rm "${file}"
      fi
    done < <(find . -mindepth 1 -not -path '*/.*' -type f)
    cd "${original_dir}"
  done
}
curl_return_ename() {
  cd "${1}"
  curl -sSLOJ \
    -w "%{filename_effective}" \
    "${2}"
}
create_lists() {
  for dir in "${@:2}"; do
    while read -r path; do
      case "${1}" in
        "GHRAW")
          BASE_URL="https://github.com/wyot1/GeoLite2-Unwalled/raw/downloads/"
          ;;
        "POTENTIAL_CDN")
          BASE_URL="https://cdn.unnamed"
          ;;
      esac
      echo "${BASE_URL}${path}" >>"./LIST/${1}/master-${dir/\//_}.lst"
    done < <(find ./"${dir}" -mindepth 1 -maxdepth 1 -type f | sed 's|^./||' \
               | sort)
  done
}
save_timestamp() {
  type=$(<<<"${1}" sed -nE 's/^GeoLite2-(.+)_[0-9]{8}\..+$/\1/p')
  if grep -wq "${type}" <<<"ASN ASN-CSV City City-CSV Country Country-CSV"; then
    new_timestamp=$(<<<"${1}" sed  -nE 's/^.+_([0-9]{8})\..+$/\1/p')
    echo "${new_timestamp}" > "${ROOT_DIR}/time/${type}"
  fi
}
MAX_SIZE=$((100 * 1024 ** 2))
ZST_LEVEL=19
TEMPDIR=$(mktemp -d)
SLEEP_MAX=15 # makes correlating this too annoying for most

mkdir -p time; touch -a time/{ASN,ASN-CSV,City,City-CSV,Country,Country-CSV}

mkdir work; cd ./work
mkdir ASN CITY COUNTRY LIST

cd ASN
mkdir CSV CSV-ZST MMDB MMDB-ZST UPSTREAM
>&2 echo "Downloading ASN"
ASN_SRC=(
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${MM_KEY}&suffix=tar.gz"
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${MM_KEY}&suffix=tar.gz.sha256"
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=${MM_KEY}&suffix=zip"
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=${MM_KEY}&suffix=zip.sha256"
)
idx=0
for src in "${ASN_SRC[@]}"; do
  sleep "$(shuf -i 0-"${SLEEP_MAX}" -n1)"
  filename=$(curl_return_ename "${TEMPDIR}" "${src}")
  save_timestamp "${filename}" 
  mv "${TEMPDIR}/${filename}" "./UPSTREAM/${idx}.${filename}"
  idx=$((++idx))
done
cp ./UPSTREAM/*.*ASN_*.tar.gz "${TEMPDIR}"
tar xf "${TEMPDIR}/"*.tar.gz -C "${TEMPDIR}"
find "${TEMPDIR}" -name "*.mmdb" -exec mv "{}" ./MMDB \;
find "${TEMPDIR}" -mindepth 1 -delete
>&2 echo "Compressing MMDB"
find ./MMDB -mindepth 1 -type f -exec zstd -q -T0 -"${ZST_LEVEL}" --long \
  --output-dir-flat ./MMDB-ZST "{}" \;
cp ./UPSTREAM/*.*ASN-CSV_*.zip "${TEMPDIR}"
unzip -q "${TEMPDIR}/"*.zip -d "${TEMPDIR}"
find "${TEMPDIR}" -name "*.csv" -exec mv "{}" ./CSV \;
find "${TEMPDIR}" -mindepth 1 -delete
>&2 echo "Compressing CSV"
find ./CSV -mindepth 1 -type f -exec zstd -q -T0 -"${ZST_LEVEL}" --long \
  --output-dir-flat ./CSV-ZST "{}" \;
>&2 echo "Looking for splits"
split_files CSV CSV-ZST MMDB MMDB-ZST UPSTREAM
cd ..

cd CITY
mkdir CSV CSV-ZST MMDB MMDB-ZST UPSTREAM
>&2 echo "Downloading CITY"
CITY_SRC=(
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MM_KEY}&suffix=tar.gz"
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MM_KEY}&suffix=tar.gz.sha256"
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&license_key=${MM_KEY}&suffix=zip"
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&license_key=${MM_KEY}&suffix=zip.sha256"
)
idx=0
for src in "${CITY_SRC[@]}"; do
  sleep "$(shuf -i 0-"${SLEEP_MAX}" -n1)"
  filename=$(curl_return_ename "${TEMPDIR}" "${src}")
  save_timestamp "${filename}" 
  mv "${TEMPDIR}/${filename}" "./UPSTREAM/${idx}.${filename}"
  idx=$((++idx))
done
cp ./UPSTREAM/*.*City_*.tar.gz "${TEMPDIR}"
tar xf "${TEMPDIR}/"*.tar.gz -C "${TEMPDIR}"
find "${TEMPDIR}" -name "*.mmdb" -exec mv "{}" ./MMDB \;
find "${TEMPDIR}" -mindepth 1 -delete
>&2 echo "Compressing MMDB"
find ./MMDB -mindepth 1 -type f -exec zstd -q -T0 -"${ZST_LEVEL}" --long \
  --output-dir-flat ./MMDB-ZST "{}" \;
cp ./UPSTREAM/*.*City-CSV_*.zip "${TEMPDIR}"
unzip -q "${TEMPDIR}/"*.zip -d "${TEMPDIR}"
find "${TEMPDIR}" -name "*.csv" -exec mv "{}" ./CSV \;
find "${TEMPDIR}" -mindepth 1 -delete
>&2 echo "Compressing CSV"
find ./CSV -mindepth 1 -type f -exec zstd -q -T0 -"${ZST_LEVEL}" --long \
  --output-dir-flat ./CSV-ZST "{}" \;
>&2 echo "Looking for splits"
split_files CSV CSV-ZST MMDB MMDB-ZST UPSTREAM
cd ..

cd COUNTRY
mkdir CSV CSV-ZST MMDB MMDB-ZST UPSTREAM
>&2 echo "Downloading COUNTRY"
COUNTRY_SRC=(
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${MM_KEY}&suffix=tar.gz"
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${MM_KEY}&suffix=tar.gz.sha256"
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${MM_KEY}&suffix=zip"
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${MM_KEY}&suffix=zip.sha256"
)
idx=0
for src in "${COUNTRY_SRC[@]}"; do
  sleep "$(shuf -i 0-"${SLEEP_MAX}" -n1)"
  filename=$(curl_return_ename "${TEMPDIR}" "${src}")
  save_timestamp "${filename}" 
  mv "${TEMPDIR}/${filename}" "./UPSTREAM/${idx}.${filename}"
  idx=$((++idx))
done
cp ./UPSTREAM/*.*Country_*.tar.gz "${TEMPDIR}"
tar xf "${TEMPDIR}/"*.tar.gz -C "${TEMPDIR}"
find "${TEMPDIR}" -name "*.mmdb" -exec mv "{}" ./MMDB \;
find "${TEMPDIR}" -mindepth 1 -delete
>&2 echo "Compressing MMDB"
find ./MMDB -mindepth 1 -type f -exec zstd -q -T0 -"${ZST_LEVEL}" --long \
  --output-dir-flat ./MMDB-ZST "{}" \;
cp ./UPSTREAM/*.*Country-CSV_*.zip "${TEMPDIR}"
unzip -q "${TEMPDIR}/"*.zip -d "${TEMPDIR}"
find "${TEMPDIR}" -name "*.csv" -exec mv "{}" ./CSV \;
find "${TEMPDIR}" -mindepth 1 -delete
>&2 echo "Compressing CSV"
find ./CSV -mindepth 1 -type f -exec zstd -q -T0 -"${ZST_LEVEL}" --long \
  --output-dir-flat ./CSV-ZST "{}" \;
>&2 echo "Looking for splits"
split_files CSV CSV-ZST MMDB MMDB-ZST UPSTREAM
cd ..

cd LIST
mkdir GHRAW JSDELIVR
cd ..
create_lists GHRAW    ASN/CSV     ASN/CSV-ZST     ASN/MMDB     \
  ASN/MMDB-ZST     ASN/UPSTREAM
create_lists GHRAW    CITY/CSV    CITY/CSV-ZST    CITY/MMDB    \
  CITY/MMDB-ZST    CITY/UPSTREAM
create_lists GHRAW    COUNTRY/CSV COUNTRY/CSV-ZST COUNTRY/MMDB \
  COUNTRY/MMDB-ZST COUNTRY/UPSTREAM

>&2 echo "Deleting tempdir"
rm -rf "${TEMPDIR}"

save_timestamp_badge build build

>&2 echo "Finished processing mm files"

