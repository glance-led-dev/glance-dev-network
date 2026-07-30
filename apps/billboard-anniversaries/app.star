# Billboard Historical Chart Rewind for Glance LED Panels.
# Uses c.text() for clean, single-line rendering with smart truncation.

def render_chart_page(c, milestone_label, song_title, artist_name):
    c.clear()

    # Left Track Sidebar (Width: 0 to 44)
    c.header(milestone_label.upper())

    # Right Content Stream Grid (Width: 1 to 126)
    
    # Safe Truncation for Song Title (Fits on 1 line using 4x7 font)
    final_title = song_title
    if len(song_title) > 30:
        final_title = song_title[:25] + "..."

    # Use c.text to guarantee NO wrapping
    c.text(
        final_title.upper(),
        1,
        12,
        font="4x7",
        color="white"
    )

    # Safe Truncation for Artist Name (Fits on 1 line using compact 3x7 font)
    final_artist = artist_name
    if len(artist_name) > 30:
        final_artist = artist_name[:100] + "..."

    # Use c.text to guarantee NO wrapping
    c.text(
        final_artist.upper(),
        1,
        24,
        font="3x7",
        color="gray"
    )

def years_10(c, ctx):
    render_chart_page(c, "10 YRS AGO", "CLOSER", "THE CHAINSMOKERS FT. HALSEY")

def years_20(c, ctx):
    render_chart_page(c, "20 YRS AGO", "PROMISCUOUS", "NELLY FURTADO FT. TIMBALAND")

def years_30(c, ctx):
    render_chart_page(c, "30 YRS AGO", "MACARENA", "LOS DEL RIO")

def years_40(c, ctx):
    render_chart_page(c, "40 YRS AGO", "SLEDGEHAMMER", "PETER GABRIEL")

def years_50(c, ctx):
    render_chart_page(c, "50 YRS AGO", "DON'T GO BREAKING MY HEART", "ELTON JOHN & KIKI DEE")
