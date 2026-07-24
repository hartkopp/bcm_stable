# Patch-Set für linux-5.15.y (isotp.c)

Antwort auf Gregs FAILED-Mail zu `can: isotp: fix use-after-free race
with concurrent NETDEV_UNREGISTER` (Message-ID
`2026072054-egging-departed-3b24@gregkh`). Enthält 2 angepasste
`isotp.c`-Patches — die vollständige Menge der 3 isotp.c-Patches aus
7.2-rc3 abzüglich des auf 5.15 bereits gequeuten (`use unconditional
synchronize_rcu() in isotp_release()`, siehe `mail/STATUS.md`).

Aufbau nachvollziehbar über `backport-isotp/linux-5.15.y` in diesem
Repo (Basis: `history-isotp/linux-5.15.y` + der bereits gequeute
Patch).

## Unterschied zu linux-5.10.y

5.15-stable trägt den `sk_error_report()`-Wrapper bereits durchgängig
in `isotp.c` (5.10 ruft noch überall `sk->sk_error_report(sk)` direkt
auf) — `0001` (isotp_tx_timeout-Teil) wendet daher hier **unverändert**
an. `0002` (isotp_init) braucht weiterhin dieselbe Anpassung wie auf
5.10.y für die zwei unabhängigen, nicht gebackporteten Vorbedingungen:

- **dynamisches `max_pdu_size`-TX-Buffer-Resizing** (`2f2dd39`, 2022,
  und `973bb01`, 2023, beide kein `Cc: stable`)
- **`hrtimer_setup()`-API-Konsolidierung**

Details je Anpassung stehen im `[ ... ]`-Abschnitt der jeweiligen
Commit-Message.

Gegen `history-isotp/master` funktionsweise verifiziert; 5.10.y und
5.15.y sind bis auf die `sk_error_report`-Stilfrage byte-identisch.

## ⚠️ Automatisch eingefügtes Signed-off-by

Auf ausdrücklichen Wunsch wurde in beiden Commits/Patches bereits

    Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

als abschließende Zeile ergänzt. Das ist eine persönliche
DCO-Zusicherung — bitte vor dem Versenden jeden Patch nochmal
wirklich gegenlesen, bevor er raus geht.

## Vor dem Versenden unbedingt prüfen

1. **Ist der bereits gequeute Patch inzwischen wirklich in
   linux-5.15.y gelandet** (nicht nur gequeued)? Lokalen
   `linux-stable`-Klon fetchen und mit `history-isotp/linux-5.15.y`
   abgleichen. Falls noch nicht gelandet: warten oder Rebase
   ankündigen (siehe Cover-Letter).
2. Test-Build/-Boot auf echtem 5.15.y-Baum, wie von den Stable-Regeln
   verlangt — das kann von hier aus nicht geprüft werden (kein
   Kernel-Build-Environment in diesem Repo).

Zum Nachbauen/Anpassen des Patch-Sets (z.B. nach einem Rebase):

```sh
git checkout backport-isotp/linux-5.15.y
git format-patch --subject-prefix="PATCH 5.15.y" \
  --in-reply-to="2026072054-egging-departed-3b24@gregkh" \
  --cover-letter -o patches-isotp/linux-5.15.y <base-commit>..HEAD
```

(Cover-Letter-Text danach wieder von Hand einfügen, `format-patch`
überschreibt ihn mit dem Platzhalter.)

## Versenden

```sh
git send-email --suppress-cc=all --confirm=always --thread=shallow \
  --to='stable@vger.kernel.org' \
  --cc="Oliver Hartkopp <socketcan@hartkopp.net>","Marc Kleine-Budde <mkl@pengutronix.de>" \
  patches-isotp/linux-5.15.y/000*.patch
```

Nur `0001` trägt `In-Reply-To`/`References` auf die FAILED-Mail dieses
Patch-Sets; `_0000-cover-letter.patch` wird nicht mitgeschickt (Präfix
`_`, daher außerhalb des `000*`-Glob, dient nur noch als Doku hier im
Repo). `--thread=shallow` lässt `git send-email` `0002`-`000N`
automatisch als Antworten auf `0001` einfädeln (`In-Reply-To` =
Message-ID von `0001`, `References` = FAILED-Mail + `0001`) - so
entsteht ein einzelner zusammenhängender Thread, ohne dass wir die
Message-ID von `0001` vorher kennen müssten.
