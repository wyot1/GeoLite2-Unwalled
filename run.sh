#!/usr/bin/env bash

set -euo pipefail

# These are necessary as gh quite often bugs inexplicably.
failsafe() {
  if ((${1} >= MAX_ATTEMPTS)); then
    FAILSAFE_NOTE="Github failed even after ${MAX_ATTEMPTS} attempts incl. "
    FAILSAFE_NOTE+="waits. Exiting to avoid tickling the rate limiter."
    >&2 echo "${FAILSAFE_NOTE}"
    exit 1
  fi
}
save_timestamp_badge() {
  timestamp_badge_json='{ "schemaVersion": 1, "label": "'"${1}"'", "message": "'"$(date -u +"%a %b %d %Y %H:%M %z")"'", "labelColor": "18122B", "color": "107CD2", "logoSvg": "<svg xmlns=\"http:\/\/www.w3.org\/2000\/svg\" viewBox=\"4 4 24 24\"><path fill=\"#fff\" d=\"M16 4a12 12 0 1 0 0 24 12 12 0 0 0 0-24Zm0 2a10 10 0 1 1 0 20 10 10 0 0 1 0-20Zm-1 2v9h7v-2h-5V8Z\"\/><\/svg>"}'
  echo "${timestamp_badge_json}" > "${ROOT_DIR}/time/${2}"
}
export -f save_timestamp_badge

>&2 echo " # Basic env info"
>&2 echo "uname: $(uname -a)"
>&2 df -h .
>&2 grep -c processor /proc/cpuinfo
>&2 grep -E 'model name' -m 1 /proc/cpuinfo
>&2 grep 'MemAvailable' /proc/meminfo

export ROOT_DIR="$(pwd)"

>&2 echo " # Testing remote for update"
mkdir -p "${ROOT_DIR}/time"
touch -a time/{ASN,ASN-CSV,City,City-CSV,Country,Country-CSV}
save_timestamp_badge check check
declare -A TEST_SET
TEST_SET=(
  [ASN]="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${MM_KEY}&suffix=tar.gz"
  [ASN-CSV]="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN-CSV&license_key=${MM_KEY}&suffix=zip"
  [City]="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${MM_KEY}&suffix=tar.gz"
  [City-CSV]="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&license_key=${MM_KEY}&suffix=zip"
  [Country]="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${MM_KEY}&suffix=tar.gz"
  [Country-CSV]="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${MM_KEY}&suffix=zip"
)
current=1
for type in "${!TEST_SET[@]}"; do
  sleep "$(shuf -i 0-15 -n1)"
  content_disposition=$(curl -sSLI -o/dev/null -w '%header{content-disposition}' "${TEST_SET[${type}]}")
  content_disposition="${content_disposition##attachment; filename=}"
  new_timestamp=$(<<<"${content_disposition}" sed  -nE 's/^.+_([0-9]{8})\..+$/\1/p')
  cur_timestamp=$(<"time/${type}")
  if [[ -z new_timestamp ]]; then
    >&2 echo " # new timestamp is empty, something's up"
    exit 1
  fi
  if (( new_timestamp > cur_timestamp )); then
     current=0
     break
  fi
done
if (( current==0 )); then
  >&2 echo " # remote is newer, allowing update"
else
  >&2 echo " # local still seems to be current, skipping build"
fi

if (( current==0 )); then
  >&2 echo " # Installing deps"
  curl -sSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /usr/share/keyrings/githubcli-archive-keyring.gpg
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  GH_CLI_REPO="deb [arch=$(dpkg --print-architecture) "
  GH_CLI_REPO+="signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] "
  GH_CLI_REPO+="https://cli.github.com/packages stable main"
  echo "${GH_CLI_REPO}" >>/etc/apt/sources.list.d/github-cli.list
  >/dev/null apt-get -yqq update
  >/dev/null apt-get -yqq install curl gh unzip zstd
  
  tmp=" # Processing the files. This includes random delays to make correlation \
  too annoying."
  >&2 echo "${tmp}"
  bash master/process_geolite2.sh
fi

>&2 echo " # Preparing git"
git config --global init.defaultBranch master
git config --global user.name "${USER_NAME}"
git config --global user.email "${USER_NAME}@users.noreply.github.com"

MAX_ATTEMPTS=10
FS_SLEEP=5

if (( current==0 )); then
  >&2 echo " # Pushing downloads to git"
  cd work
  git init
  git checkout -b downloads
  git add .
  git commit -m "${TAG_NAME}"
  git remote add origin "git@github.com:${USER_NAME}/${REPOSITORY_NAME}.git"
  # ssh is apparently less buggy than github's https
  # git remote add origin "https://${USER_NAME}:${GH_TOKEN}@github.com/\
  # ${USER_NAME}/${REPOSITORY_NAME}"
  rc=1 ; attempts=0
  while ((rc != 0)); do
    ((++attempts))
    git push -f origin downloads \
      && rc=${?} || rc=${?} && sleep "${FS_SLEEP}"
    >&2 echo "git push rc: ${rc}"
    failsafe "${attempts}"
  done
  cd ..
fi

>&2 echo " # Pushing time to git"
cd time
git remote add origin "git@github.com:${USER_NAME}/${REPOSITORY_NAME}.git" \
  || true
git checkout --orphan foo
git add -A
git commit -am "${TAG_NAME}"
git branch -D time || true
git branch -m time
rc=1 ; attempts=0
while ((rc != 0)); do
  ((++attempts))
  git push -f origin time \
    && rc=${?} || rc=${?} && sleep "${FS_SLEEP}"
  >&2 echo "git push rc: ${rc}"
  failsafe "${attempts}"
done
cd ..

if (( current==0 )); then
  >&2 echo " # Pruning"
  cd work
  rc=1 ; attempts=0
  while ((rc != 0)); do
    ((++attempts))
    git remote prune origin \
      && rc=${?} || rc=${?} && sleep "${FS_SLEEP}"
    >&2 echo "git remote prune rc: ${rc}"
    failsafe "${attempts}"
  done
  cd ..

  >&2 echo " # Creating release"
  cd work
  ls -lah
  RELEASE_NOTE="Updated files.
  Releases serve as update indicators - see the README for the master lists, and \
  an explanation. The \`downloads\` branch holds the current stack."
  rc=1 ; attempts=0
  while ((rc != 0)); do
    ((++attempts))
    gh release create -n "${RELEASE_NOTE}" "${TAG_NAME}" ../master/README.md \
      && rc=${?} || rc=${?} && sleep "${FS_SLEEP}"
    >&2 echo "gh release create rc: ${rc}"
    failsafe "${attempts}"
  done

  >&2 echo " # Deleting previous releases"
  rc=1 ; attempts=0
  while ((rc != 0)); do
    ((++attempts))
    gh release list -L 999999999 | awk '{ print $1 }' | tail -n +13 \
      | xargs -I{} gh release delete --cleanup-tag -y "{}" \
        && rc=${?} || rc=${?} && sleep "${FS_SLEEP}"
    >&2 echo "gh release delete rc: ${rc}"
    failsafe "${attempts}"
  done

  >&2 echo " # Deleting previous workflows"
  CLEAN_TIMESTAMP=$(date -u --date="-30 day" "+%Y-%m-%d")
  rc=1 ; attempts=0
  while ((rc != 0)); do
    ((++attempts))
    gh run list -R "${USER_NAME}/${REPOSITORY_NAME}" -L 999999999 \
      --json databaseId --created "<${CLEAN_TIMESTAMP}" -q '.[].databaseId' \
      | xargs -I{} gh run delete -R "${USER_NAME}/${REPOSITORY_NAME}" {} \
        && rc=${?} || rc=${?} && sleep "${FS_SLEEP}"
    >&2 echo "gh workflow delete rc: ${rc}"
    failsafe "${attempts}"
  done
fi
