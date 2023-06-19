# GeoLite2-Unwalled

*Fresh GeoLite2 databases, for everyone.*

![badge-build](https://img.shields.io/github/actions/workflow/status/wyot1/GeoLite2-Unwalled/geolite2.yml?cacheSeconds=300&labelColor=18122B&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjUgMS44OCAyMiAyOC4xNSI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTEzLjYgMkMxMi41IDIgOSAzIDcuNyA2LjRMNi40IDEwbDEgLjQtLjQuOS0xLjQuNy0uNiAxLjggNC43IDEuNy42LTEuOC0uNS0xLjQuMy0xIDEgLjRMMTIuOCA3cy0uOC0uOC0uMy0yLjJsMS0yLjl6bS4xIDUuNUwxMyA5LjNsMTEuNCA0LjItLjMgMS0xMS40LTQuMi0uNyAxLjlMMjUuMyAxN2wxLjctNC43LTEzLjMtNC44ek05IDE5djFINXYyYTMgMyAwIDAgMCAzIDNoMXYxaDV2MmgtM3YyaDEydi0yaC0zdi0yaDJhNSA1IDAgMCAwIDUtNXYtMkg5em0yIDJoMTRhMyAzIDAgMCAxLTMgM0gxMXYtM3ptLTQgMWgydjFIOGExIDEgMCAwIDEtMS0xem05IDRoMnYyaC0ydi0yeiI+PC9wYXRoPjwvc3ZnPg==) ![badge-time-build](https://img.shields.io/endpoint?cacheSeconds=300&url=https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/time/build) ![badge-time-check](https://img.shields.io/endpoint?cacheSeconds=300&url=https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/time/check)

[Download](#download) | [Security](#security) | [Support](#support) | [Joining Split Files](#joining-split-files) | [Screenshot of Member Area](#screenshot-of-member-area) | [GitHub Raw Rate Limiting](#screenshot-of-member-area) | [Legal](#legal)

MaxMind forces a login nowadays, and prohibits VPN/TOR/proxy users from even 
signing up. This is basic, monopolized data that should be available to all, 
or none.

The files can be distributed legally, and are widely used. MaxMind also offers 
commercial databases with higher accuracy, but the 'lite' version is good 
enough for research, and generic use.

Currently, MaxMind's free GeoLite2 includes *CITY*, *COUNTRY*, and 
*ASN* databases. **All files available upstream are provided "as is".**

Upstream schedule is *Tue/Fri*, as of today. GitHub runs are 
unpredictable, so we check *daily*. 

## Download

As **GitHub limits file size**, some files may have to be split. The process 
handles this automatically, if required.  
Master lists of current sets are provided for easy processing on your end.

### Master Lists

|                   |                                                ASN                                                |                                                CITY                                                |                                                COUNTRY                                                |
|-------------------|:-------------------------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------:|
| **GitHub Raw**    |                                                                                                   |                                                                                                    |                                                                                                       |
| CSV               | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-ASN_CSV.lst)           | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-CITY_CSV.lst)           | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-COUNTRY_CSV.lst)           |
| CSV-ZST           | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-ASN_CSV-ZST.lst)       | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-CITY_CSV-ZST.lst)       | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-COUNTRY_CSV-ZST.lst)       |
| MMDB              | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-ASN_MMDB.lst)          | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-CITY_MMDB.lst)          | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-COUNTRY_MMDB.lst)          |
| MMDB-ZST          | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-ASN_MMDB-ZST.lst)      | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-CITY_MMDB-ZST.lst)      | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-COUNTRY_MMDB-ZST.lst)      |
| UPSTREAM          | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-ASN_UPSTREAM.lst)      | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-CITY_UPSTREAM.lst)      | [URL](https://raw.githubusercontent.com/wyot1/GeoLite2-Unwalled/downloads/LIST/GHRAW/master-COUNTRY_UPSTREAM.lst)      |

Plug a list into your `curl`/`wget`/etc. and reliably fetch, even, if upstream 
size fluctuates. No need to mess with, or install `git`, just to get one part.

### Individual Files

It is up to you to decide how to handle it. If the filesize changes, some 
files may be split in the future that aren't today.  
You can re-use the direct links too, of course, if reliability is not a concern.

An example:

You download `GeoLite2-City.mmdb` today, it's just below GitHub's limit 
(50M soft, 100M hard), let's say 99M. Next month it's 102M, so it will be split 
into `GeoLite2-City.mmdb.00` and `GeoLite2-City.mmdb.01`.  
Now your process fails.

*If, instead, you use the master lists, you download the list, join the files 
automatically, and don't have to worry.*  
[Read on.](#joining-split-files)

If you still want a single link, the ZST version has a higher chance of staying 
below the limit.

### Compression

For convenience and saving bandwidth, re-compressed versions are also made 
available. High level zstandard is used. It's available almost everywhere and 
works well on these. (`apt install zstd`)

## Security

My process does not depend on 3rd party actions that may lead to dramas like 
the Ukraine JS malware thing. You trust only me, GitHub, and MaxMind.

Before considering using such databases for blacklisting, please think twice 
about innocent victims such as VPN/TOR/proxy users. Blacklisting countries is 
futile anyway, as state-sponsored attackers and similar modern adversaries can 
easily buy US/EU retail IPs en masse.

## Support

If this helped you, please take 5 minutes to read **insert support link**.

## Joining Split Files

I shared a guide and a ready-made bash tool on here: **insert article link**.  
It's simple and reliable, avoiding having to bother with possible filesize 
fluctuations.

Until the article is published, here's a minimal example:

```bash
curl -L \
  "https://github.com/wyot1/GeoLite2-Unwalled/raw/downloads/LIST/GHRAW/master-CITY_MMDB.lst" \
  | xargs -n1 curl -LOJ
cat GeoLite2-City.mmdb.?? > GeoLite2-City.mmdb
ls -lh
```

```
-rw-r--r-- 1 user user 69M Jun 12 08:00 GeoLite2-City.mmdb
-rw-r--r-- 1 user user 50M Jun 12 07:58 GeoLite2-City.mmdb.00
-rw-r--r-- 1 user user 19M Jun 12 07:58 GeoLite2-City.mmdb.01
```

Now you can script this to scale in your workflow, handle single files, 
split files, varying numbers. Simple and reliable.

## Screenshot of Member Area

To preclude questions, find a screenshot of the member area 
[here](./screenshot.png). That's all there is.


## GitHub Raw Rate Limiting

See [this thread][gh-rate-limit-so] for GitHub rate limits. If you use a token, 
you can get 5000 req/h regardless of IP. This might be relevant, if you're 
behind VPN/TOR/proxy/CGNAT. GitHub allows signing up via TOR where you can get 
said token.

## Legal

The code for the process is mine. The databases obviously belong to MaxMind, 
and are distributed legally.

[gh-rate-limit-so]: https://stackoverflow.com/questions/66522261/does-github-rate-limit-access-to-public-raw-files

