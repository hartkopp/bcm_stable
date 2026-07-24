# Patch-Set für linux-6.6.y

Antwort auf Gregs FAILED-Mail zu `can: bcm: add locking when updating
filter and timer values` (Message-ID `2026072011-untruth-wrongly-ed18@gregkh`).
Enthält den angepassten Backport dieses Patches sowie 7 weitere
`bcm.c`-Patches derselben Serie, die auf ihm aufbauen und aus demselben
Grund gescheitert waren — das ist die vollständige Menge der 11
bcm.c-Patches aus 7.2-rc3 abzüglich der 3 bereits gequeuten (#4/#5/#8,
siehe `mail/STATUS.md`).

Aufbau nachvollziehbar über `backport/linux-6.6.y` in diesem Repo
(Basis: `history/linux-6.6.y` + die 3 bereits gequeuten Patches).

Patches 1, 2, 7 und 8 sind gegenüber upstream angepasst: upstream
verwebt dort zusätzlich eine `traffic_flags`/`RX_LOCAL`/`RX_OWN`-
Berechnung in `bcm_rx_handler()`, die von einem eigenständigen
Feature-Commit stammt (`fec846fa7eddf7bb651bf88bd78c7db1410ae3b1`,
"add recvmsg flags for own, local and remote traffic", kein
`Cc: stable`, nie gebackported). Die zugehörigen Hunks sind
weggelassen, die jeweilige eigentliche Race-Fix ist vollständig
enthalten — Details stehen im `[ ... ]`-Abschnitt der jeweiligen
Commit-Message.

## ⚠️ Automatisch eingefügtes Signed-off-by

Auf ausdrücklichen Wunsch wurde in allen 8 Commits/Patches bereits

    Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

als abschließende Zeile ergänzt (nach der übernommenen Upstream-
Signed-off-by-Kette bzw. nach der eckigen Backport-Notiz, wo
vorhanden). Das ist eine persönliche DCO-Zusicherung — bitte vor dem
Versenden jeden Patch nochmal wirklich gegenlesen, bevor er raus geht.

## Vor dem Versenden unbedingt prüfen

1. **Sind #4/#5/#8 inzwischen wirklich in linux-6.6.y gelandet** (nicht
   nur gequeued)? Lokalen `linux-stable`-Klon fetchen und mit
   `history/linux-6.6.y` abgleichen. Falls noch nicht gelandet: warten
   oder Rebase ankündigen (siehe Cover-Letter).
2. Test-Build/-Boot auf echtem 6.6.y-Baum, wie von den Stable-Regeln
   verlangt — das kann von hier aus nicht geprüft werden (kein
   Kernel-Build-Environment in diesem Repo).

Zum Nachbauen/Anpassen des Patch-Sets (z.B. nach einem Rebase):

```sh
git checkout backport/linux-6.6.y
git format-patch --subject-prefix="PATCH 6.6.y" \
  --in-reply-to="2026072011-untruth-wrongly-ed18@gregkh" \
  --cover-letter -o patches/linux-6.6.y 43dd01e..HEAD
```

(Cover-Letter-Text danach wieder von Hand einfügen, `format-patch`
überschreibt ihn mit dem Platzhalter.)

## Versenden

```sh
git send-email --suppress-cc=all --confirm=always --thread=shallow \
  --to='stable@vger.kernel.org' \
  --cc="Oliver Hartkopp <socketcan@hartkopp.net>","Marc Kleine-Budde <mkl@pengutronix.de>" \
  patches/linux-6.6.y/000*.patch
```

Nur `0001` trägt `In-Reply-To`/`References` auf die FAILED-Mail dieses
Patch-Sets; `_0000-cover-letter.patch` wird nicht mitgeschickt (Präfix
`_`, daher außerhalb des `000*`-Glob, dient nur noch als Doku hier im
Repo). `--thread=shallow` lässt `git send-email` `0002`-`000N`
automatisch als Antworten auf `0001` einfädeln (`In-Reply-To` =
Message-ID von `0001`, `References` = FAILED-Mail + `0001`) - so
entsteht ein einzelner zusammenhängender Thread, ohne dass wir die
Message-ID von `0001` vorher kennen müssten.
