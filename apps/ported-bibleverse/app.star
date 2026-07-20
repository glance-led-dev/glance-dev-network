# Ported from the tidbyt/community "Bible Verse" app (apps/bibleverse/bible_verse.star).
#
# ORIGINAL Pixlet render: a render.Column of the colored reference (Text) above a
# render.Marquee scrolling the verse Text, from bible-api.com.
#
# `gdn translate` converted the schema.Color + schema.Dropdown to inputs and
# flagged http.* + load() and the Marquee/Column/Text widgets. Hand-finished for
# GDN (static 64x32): the marquee became statically wrapped text. The reference
# color input is honored.
#
# WHY THERE IS NO API CALL: a 64px panel holds about forty-five characters. Most
# verses are far longer than that and bible-api.com cannot filter by length, so
# a random fetch would be ellipsised into nonsense most of the time. This is a
# curated list of verses that actually fit, rotating one per day.
#
# TRANSLATION: King James Version, which is public domain. Modern translations
# (NIV, ESV, NLT) are copyrighted and cannot be redistributed in an app.

# reference, verse. Every entry is short enough to fit the body area.
VERSES = [
    ["JOHN 11:35", "JESUS WEPT."],
    ["GEN 1:3", "AND GOD SAID, LET THERE BE LIGHT."],
    ["PS 23:1", "THE LORD IS MY SHEPHERD; I SHALL NOT WANT."],
    ["PS 118:24", "THIS IS THE DAY WHICH THE LORD HATH MADE."],
    ["PS 46:10", "BE STILL, AND KNOW THAT I AM GOD."],
    ["PS 119:105", "THY WORD IS A LAMP UNTO MY FEET."],
    ["PS 27:1", "THE LORD IS MY LIGHT AND MY SALVATION."],
    ["PS 27:14", "WAIT ON THE LORD."],
    ["PS 121:1", "I WILL LIFT UP MINE EYES UNTO THE HILLS."],
    ["PS 121:2", "MY HELP COMETH FROM THE LORD."],
    ["PS 100:1", "MAKE A JOYFUL NOISE UNTO THE LORD."],
    ["PS 100:2", "SERVE THE LORD WITH GLADNESS."],
    ["PS 107:1", "O GIVE THANKS UNTO THE LORD; FOR HE IS GOOD."],
    ["PS 136:1", "HIS MERCY ENDURETH FOR EVER."],
    ["PS 34:8", "O TASTE AND SEE THAT THE LORD IS GOOD."],
    ["PS 28:7", "THE LORD IS MY STRENGTH AND MY SHIELD."],
    ["PS 51:10", "CREATE IN ME A CLEAN HEART, O GOD."],
    ["PS 19:1", "THE HEAVENS DECLARE THE GLORY OF GOD."],
    ["PS 30:5", "WEEPING MAY ENDURE FOR A NIGHT."],
    ["PROV 3:5", "TRUST IN THE LORD WITH ALL THINE HEART."],
    ["PROV 15:1", "A SOFT ANSWER TURNETH AWAY WRATH."],
    ["PROV 16:18", "PRIDE GOETH BEFORE DESTRUCTION."],
    ["PROV 17:22", "A MERRY HEART DOETH GOOD LIKE A MEDICINE."],
    ["PROV 27:17", "IRON SHARPENETH IRON."],
    ["ECCL 3:1", "TO EVERY THING THERE IS A SEASON."],
    ["ECCL 4:9", "TWO ARE BETTER THAN ONE."],
    ["ECCL 3:4", "A TIME TO WEEP, AND A TIME TO LAUGH."],
    ["ISA 40:29", "HE GIVETH POWER TO THE FAINT."],
    ["ISA 41:10", "FEAR THOU NOT; FOR I AM WITH THEE."],
    ["ISA 1:18", "COME NOW, AND LET US REASON TOGETHER."],
    ["LAM 3:23", "GREAT IS THY FAITHFULNESS."],
    ["NUM 6:24", "THE LORD BLESS THEE, AND KEEP THEE."],
    ["NEH 8:10", "THE JOY OF THE LORD IS YOUR STRENGTH."],
    ["MATT 5:7", "BLESSED ARE THE MERCIFUL."],
    ["MATT 5:8", "BLESSED ARE THE PURE IN HEART."],
    ["MATT 5:9", "BLESSED ARE THE PEACEMAKERS."],
    ["MATT 5:16", "LET YOUR LIGHT SO SHINE BEFORE MEN."],
    ["MATT 5:44", "LOVE YOUR ENEMIES."],
    ["MATT 7:7", "ASK, AND IT SHALL BE GIVEN YOU."],
    ["MATT 19:26", "WITH GOD ALL THINGS ARE POSSIBLE."],
    ["MATT 4:4", "MAN SHALL NOT LIVE BY BREAD ALONE."],
    ["MARK 4:39", "PEACE, BE STILL."],
    ["MARK 5:36", "BE NOT AFRAID, ONLY BELIEVE."],
    ["MARK 9:23", "ALL THINGS ARE POSSIBLE TO HIM THAT BELIEVETH."],
    ["JOHN 8:12", "I AM THE LIGHT OF THE WORLD."],
    ["JOHN 8:32", "THE TRUTH SHALL MAKE YOU FREE."],
    ["JOHN 14:1", "LET NOT YOUR HEART BE TROUBLED."],
    ["JOHN 14:6", "I AM THE WAY, THE TRUTH, AND THE LIFE."],
    ["JOHN 14:27", "PEACE I LEAVE WITH YOU."],
    ["ROM 1:17", "THE JUST SHALL LIVE BY FAITH."],
    ["ROM 8:28", "ALL THINGS WORK TOGETHER FOR GOOD."],
    ["ROM 12:9", "LET LOVE BE WITHOUT DISSIMULATION."],
    ["ROM 12:12", "REJOICING IN HOPE; PATIENT IN TRIBULATION."],
    ["ROM 12:21", "BE NOT OVERCOME OF EVIL."],
    ["1 COR 13:8", "CHARITY NEVER FAILETH."],
    ["1 COR 16:13", "WATCH YE, STAND FAST IN THE FAITH."],
    ["1 COR 16:14", "LET ALL YOUR THINGS BE DONE WITH CHARITY."],
    ["2 COR 5:7", "WE WALK BY FAITH, NOT BY SIGHT."],
    ["2 COR 9:7", "GOD LOVETH A CHEERFUL GIVER."],
    ["2 COR 12:9", "MY GRACE IS SUFFICIENT FOR THEE."],
    ["GAL 6:2", "BEAR YE ONE ANOTHER'S BURDENS."],
    ["GAL 6:9", "LET US NOT BE WEARY IN WELL DOING."],
    ["EPH 4:32", "BE YE KIND ONE TO ANOTHER."],
    ["EPH 5:2", "AND WALK IN LOVE."],
    ["EPH 6:11", "PUT ON THE WHOLE ARMOUR OF GOD."],
    ["PHIL 4:4", "REJOICE IN THE LORD ALWAY."],
    ["PHIL 4:13", "I CAN DO ALL THINGS THROUGH CHRIST."],
    ["PHIL 1:21", "TO LIVE IS CHRIST, AND TO DIE IS GAIN."],
    ["1 THESS 5:16", "REJOICE EVERMORE."],
    ["1 THESS 5:17", "PRAY WITHOUT CEASING."],
    ["1 THESS 5:18", "IN EVERY THING GIVE THANKS."],
    ["1 THESS 5:19", "QUENCH NOT THE SPIRIT."],
    ["1 THESS 4:11", "STUDY TO BE QUIET."],
    ["1 TIM 6:12", "FIGHT THE GOOD FIGHT OF FAITH."],
    ["HEB 13:1", "LET BROTHERLY LOVE CONTINUE."],
    ["HEB 13:6", "THE LORD IS MY HELPER."],
    ["JAMES 1:17", "EVERY GOOD GIFT IS FROM ABOVE."],
    ["JAMES 1:22", "BE YE DOERS OF THE WORD."],
    ["JAMES 2:20", "FAITH WITHOUT WORKS IS DEAD."],
    ["JAMES 4:7", "RESIST THE DEVIL, AND HE WILL FLEE."],
    ["JAMES 4:8", "DRAW NIGH TO GOD."],
    ["1 PET 2:17", "HONOUR ALL MEN. LOVE THE BROTHERHOOD."],
    ["1 PET 5:7", "CASTING ALL YOUR CARE UPON HIM."],
    ["1 PET 5:8", "BE SOBER, BE VIGILANT."],
    ["1 JOHN 4:8", "GOD IS LOVE."],
    ["REV 21:5", "BEHOLD, I MAKE ALL THINGS NEW."],
]

# Line height per font, chosen so there is ALWAYS at least a 1px gap between
# lines. 5x7 renders taller than its name suggests, so it needs 9, not 8 --
# at 8 the two lines sit flush against each other.
LINE_H = {
    "5x7": 9,
    "4x5": 6,
    "picopixel": 6,
}

# Tried biggest first.
FONTS = ["5x7", "4x5", "picopixel"]

def wrap(c, text, maxw, font):
    # Split on spaces, but chop any single word too wide to ever fit -- a
    # space-only split has no way to break one.
    words = []
    for w in text.split(" "):
        for _ in range(8):
            if c.text_width(w, font) <= maxw:
                break
            n = 1
            for k in range(1, len(w)):
                if c.text_width(w[0:k], font) > maxw:
                    break
                n = k
            words.append(w[0:n])
            w = w[n:]
        if w:
            words.append(w)

    lines = []
    cur = ""
    for w in words:
        trial = cur + " " + w if cur else w
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines

def main(c, ctx):
    ref_color = ctx.inputs.get("color", "#00FF00")
    if ref_color == None:
        ref_color = "#00FF00"

    # One verse per day. The prime stride jumps around the list instead of
    # stepping through it in order, while still reaching every entry.
    idx = (ctx.now.yday * 7919 + ctx.now.year) % len(VERSES)
    ref = VERSES[idx][0]
    verse = VERSES[idx][1]

    c.fill("black")

    ref_font = "5x7" if c.text_width(ref, "5x7") <= c.width - 2 else "4x5"
    c.text(ref, c.width // 2, 1, font = ref_font, color = ref_color, align = "center")

    # Pick the biggest font whose wrapped lines fit under the reference.
    budget = c.height - 9
    maxw = c.width - 2

    font = FONTS[len(FONTS) - 1]
    lh = LINE_H[font]
    lines = wrap(c, verse, maxw, font)

    for f in FONTS:
        cand = wrap(c, verse, maxw, f)
        if len(cand) * LINE_H[f] <= budget:
            font = f
            lh = LINE_H[f]
            lines = cand
            break

    # Never draw past the bottom edge.
    maxlines = budget // lh
    if len(lines) > maxlines:
        lines = lines[0:maxlines]

    total = len(lines) * lh
    y = 9 + max(0, (budget - total) // 2)
    for i in range(len(lines)):
        c.text(lines[i], c.width // 2, y, font = font, color = "white", align = "center")
        y = y + lh