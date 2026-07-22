# Stable-Status der bcm.c/isotp.c-Patches (Stand: Mails vom 20./21.07.2026)

Erzeugt aus den `stable@vger.kernel.org`-Statusmails in diesem Verzeichnis
(`FAILED: patch "..." failed to apply ...` / `Patch "..." has been added ...`),
zugeordnet über den in jeder Mail enthaltenen 40-stelligen Original-Commit-Hash
aus Linus' Tree (nicht über den – teils identischen – Commit-Betreff).

Reihenfolge: chronologisch wie die Commits tatsächlich auf den Mainline-Tree
angewendet wurden (Author-Datum aus `history/master` bzw. `history-isotp/master`
in diesem Repo, jeweils über den `Original-commit:`-Trailer aufgelöst).

| # | commit | Datei | Betreff | 5.10 | 5.15 | 6.1 | 6.6 | 6.12 | 6.18 | 7.1 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `9b1a02e0d980` | isotp.c | use unconditional synchronize_rcu() in isotp_release() | OK | OK | OK | OK | OK | OK | OK |
| 2 | `20bab8b88baa` | isotp.c | fix use-after-free race with concurrent NETDEV_UNREGISTER | FAIL | FAIL | FAIL | FAIL | FAIL | OK | OK |
| 3 | `cf070fe33bfb` | isotp.c | serialize TX state transitions under so->rx_lock | FAIL | FAIL | FAIL | FAIL | FAIL | OK | OK |
| 4 | `68973f9db761` | bcm.c | defer rx_op deallocation to workqueue to fix thrtimer UAF | FAIL | FAIL | OK | OK | OK | OK | OK |
| 5 | `d9b091d9d22f` | bcm.c | fix lockless bound/ifindex race and silent RX_SETUP failure | OK | OK | OK | OK | OK | OK | OK |
| 6 | `749179c2e25b` | bcm.c | add locking when updating filter and timer values | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 7 | `e6c24ba95fc3` | bcm.c | fix CAN frame rx/tx statistics | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 8 | `7b2c3eabc4da` | bcm.c | add missing rcu list annotations and operations | OK | OK | OK | OK | OK | OK | OK |
| 9 | `12ce799f7ab1` | bcm.c | extend bcm_tx_lock usage for data and timer updates | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 10 | `62ec41f36464` | bcm.c | validate frame length in bcm_rx_setup() for RTR replies | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 11 | `d59948293ea3` | bcm.c | add missing device refcount for CAN filter removal | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 12 | `3b762c0d9503` | bcm.c | fix stale rx/tx ops after device removal | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 13 | `58fd6cbc8541` | bcm.c | fix data race on rx_stamp/rx_ifindex in bcm_rx_handler() | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 14 | `2f5976f54a04` | bcm.c | track a single source interface for ANYDEV timeout/throttle ops | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |

11 der 14 Zeilen betreffen `net/can/bcm.c`, 3 (#1–#3) das begleitende
`net/can/isotp.c` aus derselben Patch-Serie.

## Beobachtungen

- Patch #5 (`d9b091d9d22f`, lockless bound/ifindex race), #8 (`7b2c3eabc4da`,
  rcu list annotations) und isotp-Patch #1 (`9b1a02e0d980`) laufen auf
  **allen** Branches glatt durch, #4 (defer rx_op deallocation) erst ab 6.1.
  Diese sind vermutlich vom regulären Stable-Prozess (Cc:-stable-Tag /
  AUTOSEL) sauber cherry-gepickt worden, weil sie unverändert auf den
  älteren Tree passen — nicht zwingend ein manueller Backport unsererseits.
  Das lässt sich aus den Mails selbst nicht eindeutig belegen.
- Die 8 übrigen `bcm.c`-Patches (#6, #7, #9–#14) scheitern **einheitlich**
  auf 5.10 bis 6.18 und laufen nur auf 7.1 glatt durch.
- Die beiden übrigen `isotp.c`-Patches (#2, #3) haben einen **anderen**
  Bruchpunkt: sie scheitern bis 6.12, laufen aber ab 6.18 (und 7.1) durch.
  `bcm.c` und `isotp.c` brauchen also unterschiedliche strukturelle
  Vorbedingungen — der Bruch liegt nicht am selben Kernel-Stand.
- Gregs Tooling liefert in keiner der 62 FAILED-Mails einen Hinweis unter
  "Possible dependencies" — es sind also keine dem Tool bekannten
  Voraussetzungs-Commits hinterlegt; die Abhängigkeiten müssen inhaltlich
  hergeleitet werden.

## Backport-Status (patches/\* und patches-isotp/\*)

| Branch | bcm.c-Patches im Set | isotp.c-Patches im Set |
|---|---|---|
| linux-5.10.y | 9 (#4, #6, #7, #9–#14) | 2 (#2, #3) |
| linux-5.15.y | 9 (#4, #6, #7, #9–#14) | 2 (#2, #3) |
| linux-6.1.y | 8 (#6, #7, #9–#14) | 2 (#2, #3) |
| linux-6.6.y | 8 (#6, #7, #9–#14) | 2 (#2, #3) |
| linux-6.12.y | 8 (#6, #7, #9–#14, unverändert) | 2 (#2, #3, #2 unverändert) |
| linux-6.18.y | 8 (#6, #7, #9–#14, unverändert) | **0** |

`linux-6.18.y` ist bei `isotp.c` ein Sonderfall: dort sind **alle drei**
Patches (#1, #2, #3) bereits selbst als "added" (nicht "FAILED") gemeldet,
also schon reine gequeued über den normalen Stable-Prozess gelandet — es
gibt keinen FAILED-Thread, auf den man antworten könnte, und nichts
nachzureichen. `backport-isotp/linux-6.18.y` existiert trotzdem als reiner
Verifikationsbeleg (alle 3 Patches wenden sauber an, deckungsgleich mit
`history-isotp/master`), aber es gibt kein `patches-isotp/linux-6.18.y`.

Bei `bcm.c` gilt dieselbe Konstellation nicht — dort scheitern #6, #7,
#9–#14 auf allen sechs Branches bis einschließlich 6.18 und erst ab 7.1
läuft alles durch, siehe Tabelle oben.

## isotp.c-Historie

Analog zu `history/*` (bcm.c) existieren `history-isotp/*`-Branches
(isotp.c) für master und alle 7 stable-Branches, erzeugt mit demselben
`tools/extract-file-history.sh` (Datei-Parameter `net/can/isotp.c`):

```sh
tools/extract-file-history.sh ~/src/linux-stable origin/master        history-isotp/master        net/can/isotp.c
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.18.y  history-isotp/linux-6.18.y  net/can/isotp.c
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.12.y  history-isotp/linux-6.12.y  net/can/isotp.c
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.6.y   history-isotp/linux-6.6.y   net/can/isotp.c
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.1.y   history-isotp/linux-6.1.y   net/can/isotp.c
tools/extract-file-history.sh ~/src/linux-stable origin/linux-5.15.y  history-isotp/linux-5.15.y  net/can/isotp.c
tools/extract-file-history.sh ~/src/linux-stable origin/linux-5.10.y  history-isotp/linux-5.10.y  net/can/isotp.c

git push -u origin $(git branch --list 'history-isotp/*' --format='%(refname:short)')
```
