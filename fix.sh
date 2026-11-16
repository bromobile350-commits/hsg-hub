#!/bin/bash
# HSG FB auto-reply: point this Mac at the hub's new address (11-17, ngrok replaced by Cloudflare). No secrets in here.
python3 - <<'PY'
import json, os, time, urllib.request
p = os.path.expanduser("~/hsgclau-workspace/fbmp/bridge/config.json")
url = json.loads(urllib.request.urlopen("https://bromobile350-commits.github.io/hsg-hub/hub_url.json?t=%d" % time.time(), timeout=20).read())["url"]
c = json.load(open(p))
old = c["hub"]["url"]
c["hub"]["url"] = url
json.dump(c, open(p + ".tmp", "w"), ensure_ascii=False, indent=2)
os.replace(p + ".tmp", p)
print("hub address:", old, "->", url)
PY
launchctl kickstart -k gui/$(id -u)/com.hsg.fbmp-bridge && echo "OK - done / 完成"
