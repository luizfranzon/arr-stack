#!/bin/sh
P=http://prowlarr:9696/api/v1
H="X-Api-Key: $PROWLARR_KEY"
until curl -sf -H "$H" $P/system/status >/dev/null; do sleep 3; done

post() { curl -sf -H "$H" -H 'Content-Type: application/json' -X POST "$P/$1" -d "$2"; }

if ! curl -sf -H "$H" $P/indexerProxy | grep -q FlareSolverr; then
  TAG=$(post tag '{"label":"flaresolverr"}' | sed 's/.*"id":\([0-9]*\).*/\1/')
  post indexerproxy "{\"name\":\"FlareSolverr\",\"implementation\":\"FlareSolverr\",\"configContract\":\"FlareSolverrSettings\",\"fields\":[{\"name\":\"host\",\"value\":\"http://flaresolverr:8191/\"},{\"name\":\"requestTimeout\",\"value\":60}],\"tags\":[$TAG]}" >/dev/null
fi

app() {
  curl -sf -H "$H" $P/applications | grep -q "\"name\":\"$1\"" && return
  post applications "{\"name\":\"$1\",\"implementation\":\"$1\",\"configContract\":\"$1Settings\",\"syncLevel\":\"fullSync\",\"fields\":[{\"name\":\"prowlarrUrl\",\"value\":\"http://prowlarr:9696\"},{\"name\":\"baseUrl\",\"value\":\"http://$(echo $1 | tr A-Z a-z):$2\"},{\"name\":\"apiKey\",\"value\":\"$3\"},{\"name\":\"syncCategories\",\"value\":[$4]}],\"tags\":[]}" >/dev/null
}
app Sonarr 8989 "$SONARR_KEY" 5000,5010,5020,5030,5040,5045,5050,5090
app Radarr 7878 "$RADARR_KEY" 2000,2010,2020,2030,2040,2045,2050,2060,2070,2080
echo "Prowlarr configurado"
