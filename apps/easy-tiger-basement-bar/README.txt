EASY TIGER BASEMENT BAR — GDN APP

WHAT THIS IS
This is a real Glance Developer Network app that preserves the spirit of your animation
using three still pages, because GDN apps do not support true frame-by-frame animation.

PAGES
1. HERO  -> giant centered tiger logo, TIGER on the left, EASY on the right
2. BLAST -> second still with larger eye-bolt effect to imply action
3. BAR   -> EASY TIGER / BASEMENT BAR with tiger logos on both sides

FILES
- manifest.yaml
- app.star
- page1.png
- page2.png
- page3.png

HOW TO INSTALL INTO GDN
1. Clone the official repo:
   git clone https://github.com/glance-led-dev/glance-dev-network.git
   cd glance-dev-network

2. Set up the environment on Mac:
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -e .

3. Create your app folder:
   mkdir -p apps/easy-tiger-basement-bar

4. Copy THESE files into:
   apps/easy-tiger-basement-bar/

5. Open Studio:
   gdn studio

6. In Studio, open the app: easy-tiger-basement-bar

7. Click Validate.
   Or from terminal:
   gdn validate apps/easy-tiger-basement-bar

8. If validation passes, you can preview and submit it.

NOTES
- This project is set to width: 384 for a Pro-width Scroll.
- If your Scroll is a narrower model, we can build a 192 px version too.
