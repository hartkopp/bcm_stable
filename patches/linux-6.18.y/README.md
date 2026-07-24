# Patch-Set für linux-6.18.y

Antwort auf Gregs FAILED-Mail zu `can: bcm: add locking when updating
filter and timer values` (Message-ID `2026072010-winner-hurried-07df@gregkh`).
Enthält 8 backportierte `bcm.c`-Patches — die vollständige Menge der
11 bcm.c-Patches aus 7.2-rc3 abzüglich der 3 auf 6.18 bereits
gequeuten (#4, #5, #8, siehe `mail/STATUS.md`).

Aufbau nachvollziehbar über `backport/linux-6.18.y` in diesem Repo
(Basis: `history/linux-6.18.y` + die 3 bereits gequeuten Patches).

## Keine Anpassung nötig

Wie bei `linux-6.12.y`: 6.18-stable trägt bereits den Commit
`fec846fa7eddf7bb651bf88bd78c7db1410ae3b1` ("add recvmsg flags for
own, local and remote traffic", Januar 2024) in seiner eigenen
Baseline. Alle 8 Patches sind unveränderte Cherry-Picks; sie
scheiterten bei Greg nur, weil #4/#5/#8 zum Testzeitpunkt noch nicht
im echten Tree waren (siehe `mail/STATUS.md`).

## ⚠️ Automatisch eingefügtes Signed-off-by

Auf ausdrücklichen Wunsch wurde in allen 8 Commits/Patches bereits

    Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

als abschließende Zeile ergänzt. Das ist eine persönliche
DCO-Zusicherung — bitte vor dem Versenden jeden Patch nochmal
wirklich gegenlesen, bevor er raus geht.

## Vor dem Versenden unbedingt prüfen

1. **Sind #4/#5/#8 inzwischen wirklich in linux-6.18.y gelandet**
   (nicht nur gequeued)? Lokalen `linux-stable`-Klon fetchen und mit
   `history/linux-6.18.y` abgleichen. Falls noch nicht gelandet:
   warten oder Rebase ankündigen (siehe Cover-Letter).
2. Test-Build/-Boot auf echtem 6.18.y-Baum, wie von den Stable-Regeln
   verlangt — das kann von hier aus nicht geprüft werden (kein
   Kernel-Build-Environment in diesem Repo).

Zum Nachbauen/Anpassen des Patch-Sets (z.B. nach einem Rebase):

```sh
git checkout backport/linux-6.18.y
git format-patch --subject-prefix="PATCH 6.18.y" \
  --in-reply-to="2026072010-winner-hurried-07df@gregkh" \
  --cover-letter -o patches/linux-6.18.y <base-commit>..HEAD
```

(Cover-Letter-Text danach wieder von Hand einfügen, `format-patch`
überschreibt ihn mit dem Platzhalter.)

## Versenden

```sh
git send-email --suppress-cc=all --confirm=always --thread=shallow \
  --to='stable@vger.kernel.org' \
  --cc="Oliver Hartkopp <socketcan@hartkopp.net>","Marc Kleine-Budde <mkl@pengutronix.de>" \
  patches/linux-6.18.y/000*.patch
```

Nur `0001` trägt `In-Reply-To`/`References` auf die FAILED-Mail dieses
Patch-Sets; `_0000-cover-letter.patch` wird nicht mitgeschickt (Präfix
`_`, daher außerhalb des `000*`-Glob, dient nur noch als Doku hier im
Repo). `--thread=shallow` lässt `git send-email` `0002`-`000N`
automatisch als Antworten auf `0001` einfädeln (`In-Reply-To` =
Message-ID von `0001`, `References` = FAILED-Mail + `0001`) - so
entsteht ein einzelner zusammenhängender Thread, ohne dass wir die
Message-ID von `0001` vorher kennen müssten.
