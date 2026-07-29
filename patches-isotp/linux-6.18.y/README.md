# Patch für linux-6.18.y (isotp.c)

Anders als die übrigen `patches-isotp/linux-*.y`-Verzeichnisse ist das
hier keine Antwort auf eine FAILED-Mail: die 3 isotp.c-Patches aus
7.2-rc3 waren auf 6.18-stable bereits regulär gelandet, bevor dieses
Repo mit ihnen befasst war. Dieses Verzeichnis enthält nur den einen
zusätzlichen, danach entstandenen Patch

    can: isotp: fix timer drain order, wakeup handling and tx_gen ordering
    (commit 050f010f920da17c1044a4f174766ad553e770b6 upstream)

als einzelnen Patch `0001-...patch` — ohne Serie, ohne Cover-Letter,
mit `6.18.y`-Tag im Betreff.

Aufbau nachvollziehbar über `backport-isotp/linux-6.18.y` in diesem
Repo (Basis: `history-isotp/linux-6.18.y`).

## Anpassung

`can_set_skb_uid()`/`can_skb_ext` (die neue, generische
skb-hash-basierte Technik zur eindeutigen Markierung von TX-Echo-Skbs)
sind erst ab mainline v7.0 verfügbar (Commit
`d4fb6514ff8ed6912a71294e6b66a5d59ee88007`, "can: use skb hash instead
of private variable in headroom"), auf 6.18-stable also noch nicht
vorhanden. Statt auf die alte `*(u32 *)cf->data`-basierte
cfecho-Zuordnung zurückzufallen, wurde eine lokale, statische
`isotp_set_skb_uid()` mit demselben Verhalten wie das echte
Upstream-Original ergänzt (einfacher monotoner `atomic_t`-Zähler, ohne
Abhängigkeit von einer versionsabhängigen RNG-API). Der Patch behält
damit die tatsächliche skb->hash-basierte cfecho-Zuordnung von
Upstream unverändert bei — ein kleinerer, treuerer Backport als ein
Downgrade auf die alte Technik. Details stehen im `[ ... ]`-Abschnitt
der Commit-Message.

Gegen `history-isotp/master` funktionsweise verifiziert: einzige
Abweichung ist die lokale `isotp_set_skb_uid()`-Hilfsfunktion anstelle
des generischen, exportierten `can_set_skb_uid()`.

## ⚠️ Automatisch eingefügtes Signed-off-by

Auf ausdrücklichen Wunsch wurde im Commit/Patch bereits

    Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

als abschließende Zeile ergänzt. Das ist eine persönliche
DCO-Zusicherung — bitte vor dem Versenden den Patch nochmal wirklich
gegenlesen, bevor er raus geht.

## Anwenden auf einen echten 6.18.y-Baum

`0001-...patch` setzt auf allen drei bereits gelandeten isotp.c-Patches
aus derselben Upstream-Serie auf (`9b1a02e0d980`, `20bab8b88baa`,
`cf070fe33bfb` — siehe `mail/STATUS.md`). In einem lokalen
`linux-stable`-Checkout, der diese noch nicht enthält, vorher
`cherrypick.sh` ausführen:

```sh
cd /pfad/zum/linux-stable-checkout
sh /pfad/zu/diesem/repo/patches-isotp/linux-6.18.y/cherrypick.sh
git am /pfad/zu/diesem/repo/patches-isotp/linux-6.18.y/0001-*.patch
```

## Vor dem Versenden unbedingt prüfen

1. **Sind die drei Voraussetzungs-Commits in der Zielversion von
   6.18.y, gegen die tatsächlich versendet wird, schon wirklich
   gelandet** (nicht nur in dem hier verwendeten Referenzstand)? Sonst
   `cherrypick.sh` wie oben vorschalten bzw. im Cover-Text erwähnen.
2. Test-Build/-Boot auf echtem 6.18.y-Baum, wie von den Stable-Regeln
   verlangt — das kann von hier aus nicht geprüft werden (kein
   Kernel-Build-Environment in diesem Repo).

Zum Nachbauen/Anpassen des Patches (z.B. nach einem Rebase):

```sh
git checkout backport-isotp/linux-6.18.y
git format-patch --subject-prefix="PATCH 6.18.y" -1 -o patches-isotp/linux-6.18.y HEAD
```

## Versenden

```sh
git send-email --suppress-cc=all --confirm=always \
  --to='stable@vger.kernel.org' \
  --cc="Oliver Hartkopp <socketcan@hartkopp.net>","Marc Kleine-Budde <mkl@pengutronix.de>" \
  patches-isotp/linux-6.18.y/0001-*.patch
```

Kein `--thread=shallow` nötig, da nur ein einzelner Patch ohne Serie
verschickt wird.
