# bcm_stable

Arbeitsrepo zur Analyse und Vorbereitung von Backports der 11 in Linux
7.2-rc3 gelandeten `net/can/bcm.c`-Patches sowie der 3 begleitenden
`net/can/isotp.c`-Patches derselben Serie auf die stable-Branches
5.10.y, 5.15.y, 6.1.y, 6.6.y, 6.12.y und 6.18.y.

## Workflow

1. Für `master` sowie jeden relevanten stable-Branch wird mit
   `tools/extract-file-history.sh` eine lineare, auf `net/can/bcm.c`
   (bzw. `net/can/isotp.c`) reduzierte Commit-Historie erzeugt und als
   eigener Branch abgelegt: `history/<branch>` bzw.
   `history-isotp/<branch>`.
2. Anhand dieser Historien (Commit-Message + `Original-commit:`-
   Trailer, der auf den Hash im lokalen linux-stable-Tree verweist)
   und der Statusmails in `mail/` wird pro Branch ermittelt, welche
   der 14 Patches (11 bcm.c + 3 isotp.c) bereits sauber angewendet
   wurden und welche fehlschlagen — siehe [mail/STATUS.md](mail/STATUS.md).
3. Für jeden Branch, auf dem Patches fehlschlagen, werden die
   nötigen Anpassungen als Commits auf `backport/<branch>` bzw.
   `backport-isotp/<branch>` erarbeitet (Basis: `history/<branch>` +
   bereits gequeute Vorbedingungen) und daraus ein versandfertiges
   Patch-Set nach `patches/<branch>/` bzw. `patches-isotp/<branch>/`
   exportiert.
4. Die finalen `bcm.c`/`isotp.c`-Stände aller Branches liegen
   zusätzlich als einzelne, historienlose Dateien nebeneinander in
   `finsrc/` bzw. `finsrc-isotp/` — zum Diffen (z.B. mit `mgdiff`),
   ohne zwischen Branches wechseln zu müssen.

## tools/extract-file-history.sh

Extrahiert die komplette Historie einer einzelnen Datei aus einem
lokalen Linux-Kernel-Git-Tree und spielt sie als lineare
Einzeldatei-Historie auf einen Branch in diesem Repo.

```sh
tools/extract-file-history.sh <linux-tree-path> <source-ref> <target-branch> [<file-path>]
```

Beispiel (aus dem Wurzelverzeichnis dieses Repos, gegen einen lokalen
`linux-stable`-Klon):

```sh
tools/extract-file-history.sh ~/src/linux-stable origin/master        history/master
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.18.y  history/linux-6.18.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.12.y  history/linux-6.12.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.6.y   history/linux-6.6.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.1.y   history/linux-6.1.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-5.15.y  history/linux-5.15.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-5.10.y  history/linux-5.10.y
```

Jeder erzeugte Commit enthält ausschließlich `bcm.c` (keine Header,
keine anderen Dateien), original Autor/Datum/Commit-Message, sowie
einen Trailer `Original-commit: <sha>`, der auf den entsprechenden
Commit im Quell-Tree verweist (Hashes können repo-übergreifend nicht
erhalten bleiben).

Danach im `bcm_stable`-Repo pushen:

```sh
git push -u origin $(git branch --list 'history/*' --format='%(refname:short)')
```

Hinweis: Das Skript legt den Ziel-Branch neu an (`--orphan`) und bricht
ab, wenn er schon existiert — für ein erneutes Erzeugen also vorher
`git branch -D <target-branch>` ausführen.

Der Datei-Parameter ist generisch nutzbar; für die begleitenden
`net/can/isotp.c`-Patches derselben Serie existiert dieselbe Historie
parallel unter dem Namensraum `history-isotp/*`.

## mail/

Enthält die Statusmails von `stable@vger.kernel.org` (Greg
Kroah-Hartman) zu den 11 `bcm.c`- und 3 begleitenden `isotp.c`-
Patches (FAILED-Reports und "has been added"-Bestätigungen, als
`.eml`). Siehe [mail/STATUS.md](mail/STATUS.md) für eine nach
Mainline-Anwendungsreihenfolge sortierte Matrix, welcher Patch auf
welchem stable-Branch bereits übernommen wurde bzw. fehlschlägt, plus
eine Übersicht der Patch-Anzahl pro Branch/Datei.

## backport/\*, backport-isotp/\* und patches/\*, patches-isotp/\*

Für Branches, auf denen Patches manuell angepasst werden müssen, gibt
es zusätzlich zu `history/<branch>` (reine Upstream-Extraktion,
unverändert) einen `backport/<branch>`-Branch mit den
handangepassten Commits (Basis: `history/<branch>` + bereits gequeute
Vorbedingungen). Aus diesem wird mit `git format-patch` ein
versandfertiges Patch-Set nach `patches/<branch>/` exportiert. Für
`net/can/isotp.c` gilt dasselbe Schema parallel unter den
Namensräumen `backport-isotp/<branch>` und `patches-isotp/<branch>`
(Basis jeweils `history-isotp/<branch>`). `linux-6.18.y` ist bei
isotp.c ein Sonderfall: alle 3 Patches sind dort bereits regulär
gequeued, `backport-isotp/linux-6.18.y` existiert nur als
Verifikationsbeleg, ein `patches-isotp/linux-6.18.y/` gibt es nicht.

Jedes `patches*/<branch>/`-Verzeichnis enthält:

- `_0000-cover-letter.patch` — Zusammenfassung der Serie, dient nur
  als Doku hier im Repo; der führende Unterstrich hält ihn bewusst
  außerhalb des `000*`-Glob, er wird **nicht** mitverschickt.
- `0001-…patch` bis `000N-…patch` — die eigentliche Serie. Nur
  `0001` trägt `In-Reply-To`/`References` auf die FAILED-Mail dieses
  Patch-Sets; `0002`–`000N` bekommen ihre Thread-Header erst beim
  Versand automatisch (siehe unten).
- `cherrypick.sh` — Prerequisite-Commits (bereits uber den normalen
  Stable-Prozess gequeued, siehe `mail/STATUS.md`), die vor `git am`
  erst in den lokalen Ziel-Tree gecherry-pickt werden müssen.
- `README.md` — Details zu den Anpassungen in dieser Serie sowie der
  exakte `git send-email`-Befehl:

  ```sh
  git send-email --suppress-cc=all --confirm=always --thread=shallow \
    --to='stable@vger.kernel.org' \
    --cc="Oliver Hartkopp <socketcan@hartkopp.net>","Marc Kleine-Budde <mkl@pengutronix.de>" \
    patches/<branch>/000*.patch
  ```

  `--thread=shallow` lässt `git send-email` `0002`–`000N` automatisch
  als Antworten auf `0001` einfädeln (`In-Reply-To` = Message-ID von
  `0001`, `References` = FAILED-Mail + `0001`) — so entsteht ein
  einzelner zusammenhängender Thread, ohne dass wir die Message-ID
  von `0001` vorher kennen müssten. Das entspricht dem Aufbau, den
  echte stable-Resubmissions auf der Mailingliste tatsächlich haben
  (kein Cover Letter, nur Patch 1 referenziert die FAILED-Mail).

## finsrc/ und finsrc-isotp/

Historienlose Momentaufnahmen des finalen `bcm.c`- bzw. `isotp.c`-
Stands jedes `backport`/`backport-isotp`-Branches, plus `master` als
Referenz (`bcm-master.c`/`isotp-master.c`), benannt nach Branch
(`bcm-510.c`, `bcm-618.c`, …). Zum direkten Nebeneinander-Vergleich
aller Versionen, ohne zwischen Branches wechseln zu müssen.

## finsrc2-isotp/

Zweite Momentaufnahme derselben `isotp.c`-Branch-Tips, diesmal
*nach* dem zusätzlichen Patch `can: isotp: fix timer drain order,
wakeup handling and tx_gen ordering` (Commit
`050f010f920da17c1044a4f174766ad553e770b6`). `finsrc-isotp/` bleibt
unverändert als Vorher-Stand stehen, so dass sich beide Verzeichnisse
gegeneinander diffen lassen, um genau zu sehen, was dieser eine Patch
pro Branch verändert hat.
