# Patch-Set für linux-6.12.y (isotp.c)

Antwort auf Gregs FAILED-Mail zu `can: isotp: fix use-after-free race
with concurrent NETDEV_UNREGISTER` (Message-ID
`2026072053-chubby-luridness-4ba8@gregkh`). Enthält 2 angepasste
`isotp.c`-Patches — die vollständige Menge der 3 isotp.c-Patches aus
7.2-rc3 abzüglich des auf 6.12 bereits gequeuten (`use unconditional
synchronize_rcu() in isotp_release()`, siehe `mail/STATUS.md`).

Aufbau nachvollziehbar über `backport-isotp/linux-6.12.y` in diesem
Repo (Basis: `history-isotp/linux-6.12.y` + der bereits gequeute
Patch).

## Identisch zu linux-6.6.y

Gleicher Umfang und dieselbe eine fehlende Vorbedingung: das
`max_pdu_size`-Feature ist bereits vorhanden, `0001` braucht daher
nur eine reine Merge-Artefakt-Auflösung. `0002` braucht weiterhin die
`hrtimer_setup()`-Anpassung, da diese API-Konsolidierung erst
zwischen 6.12- und 6.18-Branch-Off landete (dieselbe Bruchlinie wie
bei den `bcm.c`-Patches).

Gegen `history-isotp/master` funktionsweise verifiziert:
`isotp_tx_timeout()` ist byte-identisch zu master, `isotp_init()`
unterscheidet sich nur in der dokumentierten `hrtimer_setup`-Stelle.

## ⚠️ Automatisch eingefügtes Signed-off-by

Auf ausdrücklichen Wunsch wurde in beiden Commits/Patches bereits

    Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

als abschließende Zeile ergänzt. Das ist eine persönliche
DCO-Zusicherung — bitte vor dem Versenden jeden Patch nochmal
wirklich gegenlesen, bevor er raus geht.

## Vor dem Versenden unbedingt prüfen

1. **Ist der bereits gequeute Patch inzwischen wirklich in
   linux-6.12.y gelandet** (nicht nur gequeued)? Lokalen
   `linux-stable`-Klon fetchen und mit `history-isotp/linux-6.12.y`
   abgleichen. Falls noch nicht gelandet: warten oder Rebase
   ankündigen (siehe Cover-Letter).
2. Test-Build/-Boot auf echtem 6.12.y-Baum, wie von den Stable-Regeln
   verlangt — das kann von hier aus nicht geprüft werden (kein
   Kernel-Build-Environment in diesem Repo).

Zum Nachbauen/Anpassen des Patch-Sets (z.B. nach einem Rebase):

```sh
git checkout backport-isotp/linux-6.12.y
git format-patch --subject-prefix="PATCH 6.12.y" \
  --in-reply-to="2026072053-chubby-luridness-4ba8@gregkh" \
  --cover-letter -o patches-isotp/linux-6.12.y <base-commit>..HEAD
```

(Cover-Letter-Text danach wieder von Hand einfügen, `format-patch`
überschreibt ihn mit dem Platzhalter.)

## Versenden

```sh
git send-email --suppress-cc=all --confirm=always --thread=shallow \
  --to='stable@vger.kernel.org' \
  --cc="Oliver Hartkopp <socketcan@hartkopp.net>","Marc Kleine-Budde <mkl@pengutronix.de>" \
  patches-isotp/linux-6.12.y/000*.patch
```

Nur `0001` trägt `In-Reply-To`/`References` auf die FAILED-Mail dieses
Patch-Sets; `_0000-cover-letter.patch` wird nicht mitgeschickt (Präfix
`_`, daher außerhalb des `000*`-Glob, dient nur noch als Doku hier im
Repo). `--thread=shallow` lässt `git send-email` `0002`-`000N`
automatisch als Antworten auf `0001` einfädeln (`In-Reply-To` =
Message-ID von `0001`, `References` = FAILED-Mail + `0001`) - so
entsteht ein einzelner zusammenhängender Thread, ohne dass wir die
Message-ID von `0001` vorher kennen müssten.
