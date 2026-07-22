# Patch-Set für linux-6.6.y

Antwort auf Gregs FAILED-Mail zu `can: bcm: add locking when updating
filter and timer values` (Message-ID `2026072011-untruth-wrongly-ed18@gregkh`).
Enthält den angepassten Backport dieses Patches sowie 4 weitere
`bcm.c`-Patches derselben Serie, die auf ihm aufbauen und aus demselben
Grund gescheitert waren.

Aufbau nachvollziehbar über `backport/linux-6.6.y` in diesem Repo
(Basis: `history/linux-6.6.y` + die 3 bereits gequeuten Patches #4/#5/#8,
siehe `mail/STATUS.md`).

## ⚠️ Automatisch eingefügtes Signed-off-by

Auf ausdrücklichen Wunsch wurde in allen 5 Commits/Patches bereits

    Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

als abschließende Zeile ergänzt (bei Patch 1 nach der eckigen
Backport-Notiz, bei 2–5 nach der übernommenen Upstream-Signed-off-by-
Kette). Das ist eine persönliche DCO-Zusicherung — bitte vor dem
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
git send-email --to='stable@vger.kernel.org' patches/linux-6.6.y/000*.patch
```

`git send-email` erkennt die `In-Reply-To:`/`References:`-Header in den
Dateien automatisch und fädelt die Mails korrekt in den bestehenden
Thread ein; `--in-reply-to` muss auf der Kommandozeile nicht nochmal
angegeben werden.
