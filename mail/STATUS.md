# Stable-Status der 11 net/can/bcm.c-Patches (Stand: Mails vom 20./21.07.2026)

Erzeugt aus den `stable@vger.kernel.org`-Statusmails in diesem Verzeichnis
(`FAILED: patch "..." failed to apply ...` / `Patch "..." has been added ...`),
zugeordnet über den in jeder Mail enthaltenen 40-stelligen Original-Commit-Hash
aus Linus' Tree (nicht über den – teils identischen – Commit-Betreff).

Reihenfolge: chronologisch wie die Commits in `history/master` in diesem Repo
auf den Mainline-Tree angewendet wurden (`git log --reverse` + `Original-commit:`-Trailer).

| # | commit | Betreff | 5.10 | 5.15 | 6.1 | 6.6 | 6.12 | 6.18 | 7.1 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `68973f9db761` | can: bcm: defer rx_op deallocation to workqueue to fix thrtimer UAF | FAIL | FAIL | OK | OK | OK | OK | OK |
| 2 | `d9b091d9d22f` | can: bcm: fix lockless bound/ifindex race and silent RX_SETUP failure | OK | OK | OK | OK | OK | OK | OK |
| 3 | `749179c2e25b` | can: bcm: add locking when updating filter and timer values | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 4 | `e6c24ba95fc3` | can: bcm: fix CAN frame rx/tx statistics | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 5 | `7b2c3eabc4da` | can: bcm: add missing rcu list annotations and operations | OK | OK | OK | OK | OK | OK | OK |
| 6 | `12ce799f7ab1` | can: bcm: extend bcm_tx_lock usage for data and timer updates | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 7 | `62ec41f36464` | can: bcm: validate frame length in bcm_rx_setup() for RTR replies | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 8 | `d59948293ea3` | can: bcm: add missing device refcount for CAN filter removal | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 9 | `3b762c0d9503` | can: bcm: fix stale rx/tx ops after device removal | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 10 | `58fd6cbc8541` | can: bcm: fix data race on rx_stamp/rx_ifindex in bcm_rx_handler() | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |
| 11 | `2f5976f54a04` | can: bcm: track a single source interface for ANYDEV timeout/throttle ops | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | OK |

## Begleitende can: isotp:-Patches derselben Serie (nicht bcm.c, aber isotp.c)

Ebenfalls in den Mails enthalten, betreffen aber `net/can/isotp.c`:

| commit | Betreff | 5.10 | 5.15 | 6.1 | 6.6 | 6.12 | 6.18 | 7.1 |
|---|---|---|---|---|---|---|---|---|
| `9b1a02e0d9..` | can: isotp: use unconditional synchronize_rcu() in isotp_release() | OK | OK | OK | OK | OK | OK | OK |
| `20bab8b88b..` | can: isotp: fix use-after-free race with concurrent NETDEV_UNREGISTER | FAIL | FAIL | FAIL | FAIL | FAIL | OK | OK |
| `cf070fe33b..` | can: isotp: serialize TX state transitions under so->rx_lock | FAIL | FAIL | FAIL | FAIL | FAIL | OK | OK |

## Beobachtungen

- Patch #2 (`d9b091d9d22f`, lockless bound/ifindex race) und #5 (`7b2c3eabc4da`,
  rcu list annotations) laufen auf **allen** Branches glatt durch, #1 (defer
  rx_op deallocation) erst ab 6.1. Diese drei sind vermutlich vom regulären
  Stable-Prozess (Cc:-stable-Tag / AUTOSEL) sauber cherry-gepickt worden, weil
  sie unverändert auf den älteren Tree passen — nicht zwingend ein manueller
  Backport unsererseits. Das lässt sich aus den Mails selbst nicht eindeutig
  belegen.
- Alle 8 übrigen Patches scheitern **einheitlich** auf 5.10 bis 6.18 und
  laufen nur auf 7.1 glatt durch. Die Ursache ist damit vermutlich
  strukturell (Kontext-Drift in `bcm.c` seit den alten Ständen) und nicht
  branch-spezifisch unterschiedlich.
- Gregs Tooling liefert in keiner der 62 FAILED-Mails einen Hinweis unter
  "Possible dependencies" — es sind also keine dem Tool bekannten
  Voraussetzungs-Commits hinterlegt; die Abhängigkeiten müssen inhaltlich
  hergeleitet werden.

## isotp.c-Historie

Für einen direkten Vergleich kann `tools/extract-file-history.sh` analog auf
`net/can/isotp.c` angewendet werden (Datei-Parameter ist bereits generisch).
Empfohlenes Branch-Namensschema, um Kollisionen mit den `history/*`-Refs zu
vermeiden:

```sh
tools/extract-file-history.sh ~/src/linux-stable origin/master        history-isotp/master
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.18.y  history-isotp/linux-6.18.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.12.y  history-isotp/linux-6.12.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.6.y   history-isotp/linux-6.6.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-6.1.y   history-isotp/linux-6.1.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-5.15.y  history-isotp/linux-5.15.y
tools/extract-file-history.sh ~/src/linux-stable origin/linux-5.10.y  history-isotp/linux-5.10.y

git push -u origin $(git branch --list 'history-isotp/*' --format='%(refname:short)')
```
