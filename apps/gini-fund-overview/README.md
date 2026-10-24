# Gini Capital Fund Overview

Internal display of Gini Capital fund data for authorized users. The screen is for people who already have access. It does not offer an investment or promise a result.

This copy fills a Glance Pro panel, 384 by 32 pixels. The Studio panel, 192 pixels wide, uses the separate app Gini Capital Fund Ticker. The drawing file is the same. The manifest sets the width.

On this width the main line is 10x16 and the line under it is 6x8. Together, with a gap, they fit in the 32 pixel height.

## Access token

Ask a Gini Capital administrator for the read-only token.

Paste it into **Toegangstoken**. That field is an api-key. Glance stores it encrypted and sends it only from Glance servers, in the header `X-Glance-Token`.

Use a token made of letters and digits. With no token the panel shows a demo and does not call the server. The demo uses round sample figures, not live fund data.

## Funds

Select one or more codes. That choice is used when the ticker request does not answer 200.

- GCF, Core Fund
- DFF, Digital Future
- SCF, Super Commodities
- IVF, Income Value
- GSF, Global South

## Screen code

Leave **Schermcode** empty for the default set. The code is case sensitive, at most 40 characters: letters, digits, a hyphen, and an underscore. Example: `Kantoor-1`.

On the device, an underscore splits two settings before the app runs. A hyphen stays whole, because Glance splits only the first hyphen, between the field name and the value.

## What the panel shows

Eight still pages. The Scroll panel moves those pages to the left. Each fund and each message stays inside one page.

The fund code is orange. The day figure and the month to date figure are green for a plus, red for a minus, and white for zero. A message follows every two funds.
