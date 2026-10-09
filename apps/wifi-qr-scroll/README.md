# WiFi QR

Guest wifi as a sign on the wall — a QR code a phone camera joins from.

## Setting it up

1. **No API and no account.** Everything is generated on the panel.
2. Put your network name in **Network name**, exactly as it appears including capitals.
3. Put the password in **Password**. Leave it blank for an open network.
4. Set **Security** — `WPA` covers WPA, WPA2 and WPA3.
5. Optionally change the **Sign label** above the name.

## Settings

| setting | what it is |
|---|---|
| **Network name** | The wifi network name (SSID), exactly as it appears, including case. |
| **Password** *(credential)* | The wifi password. Shown on the panel in its exact case so a guest can type it, and encoded into the QR so they do not have to. Leave blank for an open network. |
| **Security** | WPA covers WPA, WPA2 and WPA3. Open means no password. |
| **Sign label** | The small heading above the network name. |
| **Show the password** | Turn off to show only the QR code, so the password is never on display. |
| **Hidden network** | Set to Yes if the network does not broadcast its name. Costs 7 characters of QR capacity. |

## Notes

- The password field is declared as a credential so it is masked while you type it, but the whole point of the app is to display it — set **Show the password** to `No` if you want the QR code only.
- Set **Hidden network** to `Yes` only if your network does not broadcast its name; it costs 7 characters of QR capacity.
- The QR is generated in-app: byte mode, error correction level L, with all eight mask patterns scored to the spec.

---

Settings ride a colon-separated render descriptor, so **a value containing `:` is cut
at the first colon before the app sees it** — which is why URLs are entered without
their scheme, or split into parts. See [CONTRIBUTING.md](../../CONTRIBUTING.md).
