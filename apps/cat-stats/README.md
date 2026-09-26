# Cat Stats

192×32 community Scroll app. Follow the [Cat Stats setup guide](https://github.com/nickolbp21-web/cat-stats#readme) for standalone credentials, device discovery, persistent history and a separate Cloudflare relay. Deploy an independent Cat Stats `/status` endpoint and enter its read key here. Keep vendor passwords in the local Cat Stats service.

Pages cover pets, food, water, fountains, litter and separate cleaning cycles and hopper status. Pet IDs and names come from your Cat Stats configuration. Blank `petid` rotates pets; hydration is household-wide unless a configured pet is selected. Priority alerts have a dedicated page; normal device pages remain visible. `--` means unavailable, not zero. Data older than 15 minutes is rejected.

Choose a Demo scenario for sample previews without network calls; select Live for your devices. PETLIBRO last-drink events are not verified yet, so real last-drink data requires a verified normalized event source. Seven-day totals require complete history from all configured fountains.

Local artwork uses official PETLIBRO and Litter-Robot wordmarks and manufacturer product images. See ASSETS.md for sources and rights status. The cat portrait is the mascot; pet names remain configurable.
