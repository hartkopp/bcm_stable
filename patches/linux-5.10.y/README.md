# Patch-Set für linux-5.10.y

Antwort auf Gregs FAILED-Mail zu `can: bcm: add locking when updating
filter and timer values` (Message-ID `2026072013-angled-grafted-e9e4@gregkh`).
Enthält 9 angepasste/backportierte `bcm.c`-Patches — die vollständige
Menge der 11 bcm.c-Patches aus 7.2-rc3 abzüglich der 2 auf 5.10
bereits gequeuten (#5 "fix lockless bound/ifindex race...", #8 "add
missing rcu list annotations...", siehe `mail/STATUS.md`).

Aufbau nachvollziehbar über `backport/linux-5.10.y` in diesem Repo
(Basis: `history/linux-5.10.y` + die 2 bereits gequeuten Patches).

## Unterschied zu linux-6.6.y

Auf 5.10 ist zusätzlich **Patch #4** (`defer rx_op deallocation to
workqueue`, `0001`) angepasst — auf 6.1.y und neuer wendet er
unverändert an, auf 5.10/5.15 nicht: der Grund ist diesmal *nicht*
das `traffic_flags`-Feature (wie bei #6/#7/#13/#14), sondern ein
komplett anderer, ebenfalls nicht auf 5.10 gebackporteter
Vorbereitungs-Commit (`edd1a7e42f1d2`, "can: bcm: registration
process optimization in bcm_module_init()", kein `Cc: stable`), der
`bcm_module_init()`/`bcm_module_exit()` auf eine goto-basierte,
fehlergeprüfte Unwind-Kette umgestellt hat. Patch `0001` fügt die
Workqueue-Aufräumarbeit stattdessen direkt in die ältere,
unrefaktorierte 5.10-Struktur ein — siehe Commit-Message für Details.

Patches `0002` (#6), `0003` (#7), `0008` (#13), `0009` (#14) sind wie
bei 6.6.y wegen des fehlenden `traffic_flags`/`RX_LOCAL`/`RX_OWN`-
Feature-Commits (`fec846fa7eddf7bb651bf88bd78c7db1410ae3b1`, kein
`Cc: stable`) angepasst. Patch `0002` brauchte zusätzlich eine
manuelle Neuverankerung in `bcm_rx_thr_handler()`, da 5.10 ein auf
neueren Branches bereits vorhandenes, unabhängiges Refactoring dieser
Funktion noch nicht hat.

Patches `0004`–`0007` (#9–#12) sind unveränderte Backports.

## ⚠️ Automatisch eingefügtes Signed-off-by

Auf ausdrücklichen Wunsch wurde in allen 9 Commits/Patches bereits

    Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

als abschließende Zeile ergänzt. Das ist eine persönliche
DCO-Zusicherung — bitte vor dem Versenden jeden Patch nochmal
wirklich gegenlesen, bevor er raus geht.

## Vor dem Versenden unbedingt prüfen

1. **Sind #5/#8 inzwischen wirklich in linux-5.10.y gelandet** (nicht
   nur gequeued)? Lokalen `linux-stable`-Klon fetchen und mit
   `history/linux-5.10.y` abgleichen. Falls noch nicht gelandet:
   warten oder Rebase ankündigen (siehe Cover-Letter).
2. Test-Build/-Boot auf echtem 5.10.y-Baum, wie von den Stable-Regeln
   verlangt — das kann von hier aus nicht geprüft werden (kein
   Kernel-Build-Environment in diesem Repo).

Zum Nachbauen/Anpassen des Patch-Sets (z.B. nach einem Rebase):

```sh
git checkout backport/linux-5.10.y
git format-patch --subject-prefix="PATCH 5.10.y" \
  --in-reply-to="2026072013-angled-grafted-e9e4@gregkh" \
  --cover-letter -o patches/linux-5.10.y <base-commit>..HEAD
```

(Cover-Letter-Text danach wieder von Hand einfügen, `format-patch`
überschreibt ihn mit dem Platzhalter.)

## Versenden

```sh
git send-email --suppress-cc=all --confirm=always --thread=shallow \
  --to='stable@vger.kernel.org' \
  --cc="Oliver Hartkopp <socketcan@hartkopp.net>","Marc Kleine-Budde <mkl@pengutronix.de>" \
  patches/linux-5.10.y/000*.patch
```

Nur `0001` trägt `In-Reply-To`/`References` auf die FAILED-Mail dieses
Patch-Sets; `_0000-cover-letter.patch` wird nicht mitgeschickt (Präfix
`_`, daher außerhalb des `000*`-Glob, dient nur noch als Doku hier im
Repo). `--thread=shallow` lässt `git send-email` `0002`-`000N`
automatisch als Antworten auf `0001` einfädeln (`In-Reply-To` =
Message-ID von `0001`, `References` = FAILED-Mail + `0001`) - so
entsteht ein einzelner zusammenhängender Thread, ohne dass wir die
Message-ID von `0001` vorher kennen müssten.
