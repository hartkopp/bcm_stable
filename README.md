# bcm_stable

Arbeitsrepo zur Analyse und Vorbereitung von Backports der 11 in Linux
7.2-rc3 gelandeten `net/can/bcm.c`-Patches auf ältere stable-Kernel
(z.B. 5.10.y, 5.15.y, 6.1.y, 6.6.y).

## Workflow

1. Die 11 mainline-Patches werden auf dem Branch dieses Repos abgelegt
   (z.B. als Patch-Dateien oder als Commits gegen eine bcm.c-Historie).
2. Für HEAD/master sowie jeden relevanten stable-Branch wird mit
   `tools/extract-file-history.sh` eine lineare, auf `net/can/bcm.c`
   reduzierte Commit-Historie erzeugt und als eigener Branch abgelegt,
   z.B. `history/master`, `history/linux-6.6.y`, `history/linux-6.1.y`,
   `history/linux-5.15.y`, `history/linux-5.10.y`.
3. Anhand dieser Historien (Commit-Message + `Original-commit:`-Trailer,
   der auf den Hash im lokalen linux-stable-Tree verweist) lassen sich
   die 11 neuen Patches den jeweiligen Branch-Ständen zuordnen und
   Konflikte/fehlende Voraussetzungen gezielt diskutieren.

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
git push -u origin history/master history/linux-6.6.y history/linux-6.1.y \
    history/linux-5.15.y history/linux-5.10.y
```

Hinweis: Das Skript legt den Ziel-Branch neu an (`--orphan`) und bricht
ab, wenn er schon existiert — für ein erneutes Erzeugen also vorher
`git branch -D <target-branch>` ausführen.

Der Datei-Parameter ist generisch nutzbar; für die begleitenden
`net/can/isotp.c`-Patches derselben Serie existiert dieselbe Historie
parallel unter dem Namensraum `history-isotp/*`, siehe
[mail/STATUS.md](mail/STATUS.md).

## mail/

Enthält die Statusmails von `stable@vger.kernel.org` (Greg Kroah-Hartman)
zu den 11 `bcm.c`- und 3 begleitenden `isotp.c`-Patches. Siehe
[mail/STATUS.md](mail/STATUS.md) für eine nach Mainline-Anwendungsreihenfolge
sortierte Matrix, welcher Patch auf welchem stable-Branch bereits
übernommen wurde bzw. fehlschlägt.

## backport/\* und patches/\*

Für Branches, auf denen Patches wirklich manuell angepasst werden
müssen, gibt es zusätzlich zu `history/<branch>` (reine
Upstream-Extraktion, unverändert) einen `backport/<branch>`-Branch mit
den handangepassten Commits (Basis: `history/<branch>` + bereits
gequeute Vorbedingungen). Aus diesem wird mit `git format-patch` ein
versandfertiges Patch-Set nach `patches/<branch>/` exportiert
(0000-cover-letter + 0001…, `In-Reply-To`/`References` auf die
jeweilige FAILED-Mail gesetzt). Siehe `patches/<branch>/README.md` für
die Schritte vor dem tatsächlichen `git send-email`.
