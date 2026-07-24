# Patch-Set für linux-5.10.y (isotp.c)

Antwort auf Gregs FAILED-Mail zu `can: isotp: fix use-after-free race
with concurrent NETDEV_UNREGISTER` (Message-ID
`2026072055-errand-ending-927c@gregkh`). Enthält 2 angepasste
`isotp.c`-Patches — die vollständige Menge der 3 isotp.c-Patches aus
7.2-rc3 abzüglich des auf 5.10 bereits gequeuten (`use unconditional
synchronize_rcu() in isotp_release()`, siehe `mail/STATUS.md`).

Aufbau nachvollziehbar über `backport-isotp/linux-5.10.y` in diesem
Repo (Basis: `history-isotp/linux-5.10.y` + der bereits gequeute
Patch).

## Anpassungen

Dieselbe Art von Lücken wie schon bei den `bcm.c`-Patches, diesmal
drei unabhängige, nicht auf 5.10 gebackportete Vorbedingungen:

- **dynamisches `max_pdu_size`-TX-Buffer-Resizing** (`2f2dd39` "set
  max PDU size to 64 kByte", 2022, und `973bb01` "add module
  parameter for maximum pdu size", 2023, beide kein `Cc: stable`) —
  betrifft `0001` (isotp_sendmsg) und `0002` (isotp_init).
- **`hrtimer_setup()`-API-Konsolidierung** (generischer Kernel-Umbau,
  nicht isotp-spezifisch) — betrifft `0002` (isotp_init: alte
  `hrtimer_init()`+`.function=`-Form beibehalten, inkl. des neuen
  `echotimer`, der echter Bestandteil von `0002` ist).
- **`sk_error_report()`-Wrapper** (generische Socket-Core-API, nicht
  vorhanden) — betrifft `0002` (isotp_tx_timeout): weiterhin
  `sk->sk_error_report(sk)` wie überall sonst in der Datei.

Details je Anpassung stehen im `[ ... ]`-Abschnitt der jeweiligen
Commit-Message.

Gegen `history-isotp/master` funktionsweise verifiziert: die einzigen
übrigen Abweichungen zu master (z.B. `can_skb_ext` vs. `can_skb_priv`,
`sockaddr_unsized`, ein separater UAF-Fix vom März 2026 mit eigenem
`Cc: stable`) stammen aus komplett unabhängigen, nicht zu dieser
Serie gehörenden Commits und wurden unverändert gelassen.

## ⚠️ Automatisch eingefügtes Signed-off-by

Auf ausdrücklichen Wunsch wurde in beiden Commits/Patches bereits

    Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

als abschließende Zeile ergänzt. Das ist eine persönliche
DCO-Zusicherung — bitte vor dem Versenden jeden Patch nochmal
wirklich gegenlesen, bevor er raus geht.

## Vor dem Versenden unbedingt prüfen

1. **Ist der bereits gequeute Patch inzwischen wirklich in
   linux-5.10.y gelandet** (nicht nur gequeued)? Lokalen
   `linux-stable`-Klon fetchen und mit `history-isotp/linux-5.10.y`
   abgleichen. Falls noch nicht gelandet: warten oder Rebase
   ankündigen (siehe Cover-Letter).
2. Test-Build/-Boot auf echtem 5.10.y-Baum, wie von den Stable-Regeln
   verlangt — das kann von hier aus nicht geprüft werden (kein
   Kernel-Build-Environment in diesem Repo).

Zum Nachbauen/Anpassen des Patch-Sets (z.B. nach einem Rebase):

```sh
git checkout backport-isotp/linux-5.10.y
git format-patch --subject-prefix="PATCH 5.10.y" \
  --in-reply-to="2026072055-errand-ending-927c@gregkh" \
  --cover-letter -o patches-isotp/linux-5.10.y <base-commit>..HEAD
```

(Cover-Letter-Text danach wieder von Hand einfügen, `format-patch`
überschreibt ihn mit dem Platzhalter.)

## Versenden

```sh
git send-email --suppress-cc=all --confirm=always --thread=shallow \
  --to='stable@vger.kernel.org' \
  --cc="Oliver Hartkopp <socketcan@hartkopp.net>","Marc Kleine-Budde <mkl@pengutronix.de>" \
  patches-isotp/linux-5.10.y/000*.patch
```

Nur `0001` trägt `In-Reply-To`/`References` auf die FAILED-Mail dieses
Patch-Sets; `_0000-cover-letter.patch` wird nicht mitgeschickt (Präfix
`_`, daher außerhalb des `000*`-Glob, dient nur noch als Doku hier im
Repo). `--thread=shallow` lässt `git send-email` `0002`-`000N`
automatisch als Antworten auf `0001` einfädeln (`In-Reply-To` =
Message-ID von `0001`, `References` = FAILED-Mail + `0001`) - so
entsteht ein einzelner zusammenhängender Thread, ohne dass wir die
Message-ID von `0001` vorher kennen müssten.
