"""GIF Studio, a local web GUI for turning your own PNGs into panel-accurate animated GIFs.

Sister tool to Glance Dev Studio (gdn/studio.py). You pick a size (64, 192, or 384 wide,
always 32 tall), drop PNGs in as frames, arrange and time them, and export an animated .gif.
Everything saves to a `gifs/` folder in your project, one folder per GIF.

    gdn gifstudio            open the GIF maker (http://127.0.0.1:8767)
"""
from __future__ import annotations

# Allow `python gdn/studio_gif.py` (no package) by re-entering through the CLI.
if __name__ == "__main__" and not __package__:
    import os as _os, sys as _sys
    _sys.path.insert(0, _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__))))
    from gdn.cli import main as _main
    raise SystemExit(_main(["gifstudio", *_sys.argv[1:]]))

import base64
import io
import json
import re
import webbrowser
from pathlib import Path

from flask import Flask, Response, jsonify, request

from .studio import _CSS

WIDTHS = (64, 192, 384)
HEIGHT = 32
PORT = 8767

# RGB565 lookup: round each 8-bit channel to what the 5-6-5 panel can show, so the preview
# and the exported GIF display the same colors the hardware would (mirrors colors.quantize565).
_LUT_R = [(v & 0xF8) | ((v & 0xF8) >> 5) for v in range(256)]
_LUT_G = [(v & 0xFC) | ((v & 0xFC) >> 6) for v in range(256)]
_LUT_565 = _LUT_R + _LUT_G + _LUT_R          # R, G, B bands for Image.point


def _panelize(im):
    return im.convert("RGB").point(_LUT_565)


def _hex_rgb(s, default=(0, 0, 0)):
    s = (s or "").lstrip("#")
    try:
        return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))
    except (ValueError, IndexError):
        return default


def _slug(name):
    s = re.sub(r"[^a-z0-9]+", "-", (name or "").lower()).strip("-")
    return s or "my-gif"


def _find_gifs_root(start: Path) -> Path:
    """Find (or create) the project's gifs/ folder: reuse an existing gifs/, else put one
    next to the apps/ folder, else make one under the launch dir."""
    start = start.resolve()
    for d in [start, *start.parents]:
        if (d / "gifs").is_dir():
            return d / "gifs"
        if (d / "apps").is_dir():
            (d / "apps").parent  # noqa
            g = d / "gifs"; g.mkdir(exist_ok=True); return g
    (start / "gifs").mkdir(parents=True, exist_ok=True)
    return start / "gifs"


def _default_config(name, width):
    return {"name": name, "width": int(width), "height": HEIGHT,
            "background": "#000000", "fps": 8, "loop": 0, "frames": []}


def _load_config(proj: Path):
    try:
        cfg = json.loads((proj / "gif.json").read_text(encoding="utf-8"))
    except Exception:  # noqa: BLE001
        cfg = _default_config(proj.name, 192)
    cfg.setdefault("width", 192); cfg.setdefault("height", HEIGHT)
    cfg.setdefault("background", "#000000"); cfg.setdefault("fps", 8)
    cfg.setdefault("loop", 0); cfg.setdefault("frames", [])
    return cfg


def _save_config(proj: Path, cfg):
    (proj / "gif.json").write_text(json.dumps(cfg, indent=2), encoding="utf-8", newline="\n")


def _next_frame_name(frames_dir: Path, stem, n_existing):
    stem = re.sub(r"-{2,}", "-", re.sub(r"[^a-z0-9._-]+", "-", (stem or "frame").lower())).strip("-.") or "frame"
    base = f"{n_existing + 1:04d}-{stem}.png"
    final, k = base, 2
    while (frames_dir / final).exists():
        final = f"{n_existing + 1:04d}-{stem}-{k}.png"; k += 1
    return final


def _fit_png(raw, width, bg):
    """Return PNG bytes of `raw` scaled to fit width x 32 and letterboxed onto `bg`."""
    from PIL import Image
    im = Image.open(io.BytesIO(raw)); im.load()
    im = im.convert("RGBA")
    w, h = width, HEIGHT
    k = min(w / im.width, h / im.height)
    if k < 1:                                  # only shrink; keep small pixel art crisp
        im = im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.LANCZOS)
    canvas = Image.new("RGBA", (w, h), _hex_rgb(bg) + (255,))
    canvas.alpha_composite(im, ((w - im.width) // 2, (h - im.height) // 2))
    out = io.BytesIO(); canvas.save(out, "PNG")
    return out.getvalue()


def _frame_datauri(proj: Path, fname):
    from PIL import Image
    try:
        im = _panelize(Image.open(proj / "frames" / fname))
    except Exception:  # noqa: BLE001
        return ""
    buf = io.BytesIO(); im.save(buf, "PNG")
    return "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def create_server(gifs_root: Path):
    server = Flask(__name__)
    base = gifs_root
    base.mkdir(parents=True, exist_ok=True)

    @server.after_request
    def _no_cache(resp):
        resp.headers["Cache-Control"] = "no-store, must-revalidate"
        return resp

    def _projects():
        return sorted(p.name for p in base.iterdir() if (p / "gif.json").exists())

    def _resolve():
        name = request.args.get("gif", "")
        p = (base / name).resolve()
        if p.parent != base.resolve() or not (p / "gif.json").exists():
            raise FileNotFoundError(name)
        return p

    @server.get("/")
    def home():
        html = _GIF_HTML.replace("__CSS__", _CSS + _GIF_CSS).replace("__JS__", _GIF_JS)
        return Response(html, mimetype="text/html")

    @server.get("/gifs.json")
    def gifs_list():
        return jsonify({"ok": True, "gifs": _projects()})

    @server.post("/new")
    def new_gif():
        data = request.get_json(force=True, silent=True) or {}
        name = str(data.get("name", "")).strip()
        if not name:
            return jsonify({"ok": False, "error": "Give your GIF a name first."})
        try:
            width = int(data.get("width", 192))
        except (TypeError, ValueError):
            width = 192
        if width not in WIDTHS:
            return jsonify({"ok": False, "error": "Pick a size of 64, 192, or 384."})
        slug = _slug(name)
        proj = base / slug
        if proj.exists():
            return jsonify({"ok": False, "error": f"A GIF named {slug!r} already exists."})
        (proj / "frames").mkdir(parents=True, exist_ok=True)
        _save_config(proj, _default_config(name, width))
        return jsonify({"ok": True, "gif": slug})

    @server.get("/project.json")
    def project_json():
        try:
            proj = _resolve()
        except FileNotFoundError:
            return jsonify({"ok": False, "error": "That GIF isn't here anymore."})
        cfg = _load_config(proj)
        frames = [{"file": f["file"], "duration": f.get("duration"),
                   "dataUri": _frame_datauri(proj, f["file"]), "w": cfg["width"], "h": cfg["height"]}
                  for f in cfg["frames"] if (proj / "frames" / f["file"]).exists()]
        return jsonify({"ok": True, "gif": {"name": cfg["name"], "width": cfg["width"],
                        "height": cfg["height"], "fps": cfg["fps"], "loop": cfg["loop"],
                        "background": cfg["background"]}, "frames": frames})

    @server.post("/upload-frame")
    def upload_frame():
        from PIL import Image
        try:
            proj = _resolve()
        except FileNotFoundError:
            return jsonify({"ok": False, "error": "Open or create a GIF first."})
        cfg = _load_config(proj)
        files = request.files.getlist("file")
        if not files:
            return jsonify({"ok": False, "error": "No file arrived."})
        added = []
        for f in files:
            raw = f.read(8 * 1024 * 1024 + 1)
            if len(raw) > 8 * 1024 * 1024:
                return jsonify({"ok": False, "error": "One image is over 8 MB. Use smaller files."})
            try:
                probe = Image.open(io.BytesIO(raw)); probe.load()
            except Exception:  # noqa: BLE001
                return jsonify({"ok": False, "error": "That file isn't an image Studio can read."})
            if probe.format != "PNG":
                return jsonify({"ok": False, "error": f"That's a {probe.format or 'non-PNG'} file. Frames must be PNGs."})
            name = _next_frame_name(proj / "frames", Path(f.filename or "frame").stem, len(cfg["frames"]))
            (proj / "frames" / name).write_bytes(_fit_png(raw, cfg["width"], cfg["background"]))
            cfg["frames"].append({"file": name, "duration": None}); added.append(name)
        _save_config(proj, cfg)
        return jsonify({"ok": True, "added": added})

    @server.post("/frame-op")
    def frame_op():
        try:
            proj = _resolve()
        except FileNotFoundError:
            return jsonify({"ok": False, "error": "Open a GIF first."})
        cfg = _load_config(proj); fr = cfg["frames"]
        data = request.get_json(force=True, silent=True) or {}
        op = data.get("op"); i = int(data.get("index", -1))
        if op == "blank":
            from PIL import Image
            name = _next_frame_name(proj / "frames", "blank", len(fr))
            buf = io.BytesIO(); Image.new("RGBA", (cfg["width"], HEIGHT), _hex_rgb(cfg["background"]) + (255,)).save(buf, "PNG")
            (proj / "frames" / name).write_bytes(buf.getvalue())
            fr.append({"file": name, "duration": None})
        elif op == "copy-last" and fr:
            src = proj / "frames" / fr[-1]["file"]
            name = _next_frame_name(proj / "frames", "copy", len(fr))
            (proj / "frames" / name).write_bytes(src.read_bytes())
            fr.append({"file": name, "duration": fr[-1].get("duration")})
        elif 0 <= i < len(fr):
            if op == "delete":
                fr.pop(i)
            elif op == "duplicate":
                src = proj / "frames" / fr[i]["file"]
                name = _next_frame_name(proj / "frames", "copy", len(fr))
                (proj / "frames" / name).write_bytes(src.read_bytes())
                fr.insert(i + 1, {"file": name, "duration": fr[i].get("duration")})
            elif op == "move":
                to = max(0, min(len(fr) - 1, int(data.get("to", i))))
                fr.insert(to, fr.pop(i))
            elif op == "duration":
                d = data.get("duration")
                fr[i]["duration"] = int(d) if d else None
        else:
            return jsonify({"ok": False, "error": "Nothing to do."})
        _save_config(proj, cfg)
        return jsonify({"ok": True})

    @server.post("/save")
    def save_meta():
        try:
            proj = _resolve()
        except FileNotFoundError:
            return jsonify({"ok": False, "error": "Open a GIF first."})
        cfg = _load_config(proj)
        data = request.get_json(force=True, silent=True) or {}
        if "fps" in data:
            cfg["fps"] = max(1, min(60, int(data["fps"] or 8)))
        if "loop" in data:
            cfg["loop"] = max(0, int(data["loop"] or 0))
        if "background" in data and re.match(r"^#[0-9a-fA-F]{6}$", str(data["background"] or "")):
            cfg["background"] = data["background"]
        _save_config(proj, cfg)
        return jsonify({"ok": True})

    @server.post("/export")
    def export_gif():
        from PIL import Image
        try:
            proj = _resolve()
        except FileNotFoundError:
            return jsonify({"ok": False, "error": "Open a GIF first."})
        cfg = _load_config(proj)
        if not cfg["frames"]:
            return jsonify({"ok": False, "error": "Add at least one frame first."})
        imgs, durations = [], []
        default_ms = round(1000 / max(1, cfg["fps"]))
        for f in cfg["frames"]:
            fp = proj / "frames" / f["file"]
            if not fp.exists():
                continue
            im = _panelize(Image.open(fp)).quantize(colors=256, method=Image.Quantize.MEDIANCUT,
                                                     dither=Image.Dither.NONE)
            imgs.append(im); durations.append(int(f.get("duration") or default_ms))
        if not imgs:
            return jsonify({"ok": False, "error": "No frames to export."})
        out = proj / (proj.name + ".gif")
        imgs[0].save(out, save_all=True, append_images=imgs[1:], duration=durations,
                     loop=int(cfg["loop"]), disposal=2, optimize=False)
        return jsonify({"ok": True, "file": out.name, "bytes": out.stat().st_size, "frames": len(imgs)})

    @server.get("/gif-file")
    def gif_file():
        try:
            proj = _resolve()
        except FileNotFoundError:
            return ("not found", 404)
        f = proj / (proj.name + ".gif")
        if not f.exists():
            return ("no gif yet, export it first", 404)
        return Response(f.read_bytes(), mimetype="image/gif",
                        headers={"Content-Disposition": f'attachment; filename="{proj.name}.gif"'})

    return server


def serve(start_dir=".", host="127.0.0.1", port: int = PORT, open_browser: bool = True):
    import socket
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as probe:
        probe.settimeout(0.3)
        if probe.connect_ex((host, port)) == 0:
            raise SystemExit(
                f"GIF Studio already appears to be running at http://{host}:{port}/\n"
                "Open that in your browser, or stop the other one (Ctrl+C in its terminal).")
    gifs_root = _find_gifs_root(Path(start_dir))
    server = create_server(gifs_root)
    url = f"http://{host}:{port}/"
    print(f"GIF Studio: {url}   (saving to {gifs_root})   (Ctrl+C to stop)")
    if open_browser:
        try:
            webbrowser.open(url)
        except Exception:  # noqa: BLE001
            pass
    server.run(host=host, port=port, debug=False, use_reloader=False, threaded=True)


# ============================================================================
# The page (CSS / HTML / JS).
# ============================================================================
_GIF_CSS = r"""
.gifmain { flex: 1; display: block; overflow: auto; padding: 16px 22px; min-height: 0; }
#stage { display: flex; justify-content: center; padding: 16px; }
.playbar { display: flex; align-items: center; gap: 12px; margin: 10px 4px 0; }
.playbar input[type=range] { flex: 1; }
.framelbl { font: 600 12px 'JetBrains Mono', ui-monospace, monospace; color: var(--muted); min-width: 56px; text-align: right; }
.giftimeline { margin-top: 18px; }
.tl-head { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
.timeline { display: flex; gap: 8px; overflow-x: auto; padding: 8px; background: var(--surface2);
  border: 1px solid var(--border); border-radius: 10px; min-height: 72px; align-items: center; }
.thumb { position: relative; flex: 0 0 auto; border: 2px solid transparent; border-radius: 7px;
  background: #000; cursor: pointer; padding: 0; overflow: hidden; }
.thumb.sel { border-color: var(--green); }
.thumb img { display: block; image-rendering: pixelated; }
.thumb .fn { position: absolute; top: 2px; left: 4px; font: 700 10px 'JetBrains Mono', monospace; color: #fff; text-shadow: 0 1px 2px #000; }
.thumb .fd { position: absolute; bottom: 1px; right: 4px; font: 700 9px 'JetBrains Mono', monospace; color: var(--green-soft); text-shadow: 0 1px 2px #000; }
.thumb .tbtns { position: absolute; top: 0; right: 0; display: none; gap: 2px; padding: 2px; }
.thumb.sel .tbtns { display: flex; }
.thumb .tbtns button { padding: 0 4px; font-size: 11px; line-height: 16px; border-radius: 4px;
  background: rgba(0,0,0,.7); color: #fff; border: 1px solid var(--border2); }
.tl-hint { margin: 8px 2px 0; font-size: 12px; }
.gifcards { display: flex; gap: 14px; margin-top: 18px; flex-wrap: wrap; }
.gifcards .card { flex: 1; min-width: 260px; }
.card-title { font-weight: 700; margin-bottom: 8px; }
.setgrid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 10px; }
.setrow { display: flex; flex-direction: column; gap: 4px; font-size: 12px; color: var(--muted); }
.setrow input, .setrow select { padding: 5px 8px; background: var(--surface); color: var(--text);
  border: 1px solid var(--border2); border-radius: 8px; font: inherit; font-size: 12.5px; }
#exportmsg a { color: var(--green-soft); font-weight: 700; }
body.dropping::after { content: "Drop PNGs to add frames"; }
"""

_GIF_HTML = """<!doctype html><html><head><meta charset="utf-8">
<title>GIF Studio</title><style>__CSS__</style></head><body>
<header>
  <span class="brand"><span class="dot"></span> GIF Studio</span>
  <label class="applbl">GIF
    <span class="appwrap">
      <input id="gifsel" placeholder="Search GIFs&hellip;" autocomplete="off">
      <div class="appmenu" id="gifmenu" role="listbox" hidden></div>
    </span>
  </label>
  <button class="ghost" id="newbtn">+ New GIF</button>
  <span class="spacer"></span>
  <span class="status" id="status">Ready</span>
  <button class="accent" id="exportbtn">Export GIF</button>
</header>
<main class="gifmain">
  <section class="right">
    <div class="pane-head rhead">
      <span class="ptitle">Preview</span>
      <label class="toggle" title="Draw a faint line around every pixel"><input type="checkbox" id="grid" checked> Pixel grid</label>
      <span class="spacer"></span>
      <span class="coords" id="coords">x, y</span>
    </div>
    <div class="rbody">
      <div id="stage"><p class="rhint">Make or open a GIF to start.</p></div>
      <div class="playbar" id="playbar" hidden>
        <button class="ghost small" id="playbtn">&#9654; Play</button>
        <input type="range" id="scrub" min="0" value="0">
        <span class="framelbl" id="framelbl">&ndash;</span>
      </div>
    </div>
  </section>

  <section class="giftimeline">
    <div class="tl-head"><b>Frames</b><span class="dim" id="tlcount"></span>
      <span class="spacer"></span>
      <button class="ghost small" id="addblank">+ Blank frame</button>
      <button class="ghost small" id="copylast">Copy last</button>
    </div>
    <div class="timeline" id="timeline"></div>
    <p class="dim tl-hint">Drag PNGs onto the window to add them as frames. Select a frame to move, copy, or delete it.</p>
  </section>

  <section class="gifcards">
    <div class="card">
      <div class="card-title">Timing &amp; loop</div>
      <div class="setgrid">
        <label class="setrow"><span>Frames per second</span><input type="number" id="fps" min="1" max="60" value="8"></label>
        <label class="setrow"><span>Selected frame (ms)</span><input type="number" id="fdur" min="0" placeholder="uses fps"></label>
        <label class="setrow"><span>Loop</span>
          <select id="loop"><option value="0">Forever</option><option value="1">Once</option>
            <option value="2">Twice</option><option value="4">4 times</option></select></label>
        <label class="setrow"><span>Background</span><input type="color" id="bg" value="#000000"></label>
      </div>
    </div>
    <div class="card" id="exportcard">
      <div class="card-title">Export</div>
      <p class="dim">Builds <code id="exportname">your.gif</code> in the GIF's folder, in the colors the
      panel actually shows. Click <b>Export GIF</b> (top right) to build and download it.</p>
      <div id="exportmsg" class="dim"></div>
    </div>
  </section>
</main>

<div class="overlay" id="newmodal" hidden>
  <div class="modal">
    <h2>New GIF</h2>
    <label class="mlabel">Name<input id="newname" class="mfull" placeholder="My animation" maxlength="60" autocomplete="off"></label>
    <label class="mlabel">Size
      <select id="newwidth">
        <option value="64">64 x 32 (one panel)</option>
        <option value="192" selected>192 x 32 (three panels)</option>
        <option value="384">384 x 32 (six panels, the max)</option>
      </select></label>
    <div class="newslug" id="newslug">Folder: gifs/my-animation</div>
    <div class="mErr" id="newerr"></div>
    <div class="modal-btns"><button class="ghost" id="newcancel">Cancel</button><button class="accent" id="newok">Create GIF</button></div>
  </div>
</div>

<script>__JS__</script>
</body></html>"""

_GIF_JS = r"""
function $(id){return document.getElementById(id);}
function esc(s){return String(s==null?'':s).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));}
function setStatus(m,k){const s=$('status'); s.textContent=m||''; s.className='status'+(k?(' '+k):'');}
let cur=null, project=null, frames=[], sel=0, playing=false, playTimer=null;
function gifQS(){return 'gif='+encodeURIComponent(cur||'');}

async function loadGifs(pick){
  let d; try{ d=await (await fetch('gifs.json')).json(); }catch(e){ setStatus('Couldn\'t reach GIF Studio.','bad'); return; }
  const list=d.gifs||[];
  if(!list.length){ $('gifsel').placeholder='No GIFs yet, click + New GIF'; return; }
  const want = pick || cur || list[0];
  openGif(list.includes(want)?want:list[0]);
}
async function openGif(slug){
  cur=slug; $('gifsel').value=slug;
  let d; try{ d=await (await fetch('project.json?'+gifQS())).json(); }catch(e){ setStatus('Couldn\'t open that GIF.','bad'); return; }
  if(!d.ok){ setStatus(d.error,'bad'); return; }
  project=d.gif; frames=d.frames||[]; sel=Math.min(sel,Math.max(0,frames.length-1));
  $('fps').value=project.fps; $('loop').value=String(project.loop); $('bg').value=project.background||'#000000';
  $('exportname').textContent=slug+'.gif';
  renderTimeline(); buildStage(); setStatus('Ready');
}
function renderTimeline(){
  $('tlcount').textContent=frames.length?(' · '+frames.length+' frame'+(frames.length!==1?'s':'')):'';
  const scale = 2;
  $('timeline').innerHTML = frames.map((f,i)=>{
    const dur = f.duration ? (f.duration+'ms') : '';
    return '<button class="thumb'+(i===sel?' sel':'')+'" data-i="'+i+'">'+
      '<img src="'+f.dataUri+'" width="'+(f.w*scale)+'" height="'+(f.h*scale)+'">'+
      '<span class="fn">'+(i+1)+'</span>'+(dur?'<span class="fd">'+dur+'</span>':'')+
      '<span class="tbtns"><button data-op="move-l" title="Move left">&#8592;</button>'+
      '<button data-op="dup" title="Duplicate">&#43;</button>'+
      '<button data-op="del" title="Delete">&times;</button>'+
      '<button data-op="move-r" title="Move right">&#8594;</button></span></button>';
  }).join('') || '<span class="dim">No frames yet.</span>';
}
function buildStage(){
  const stage=$('stage');
  if(!frames.length){ stage.innerHTML='<p class="rhint">Drop some PNGs to add frames.</p>'; $('playbar').hidden=true; return; }
  const avail=Math.max(220, stage.clientWidth-32);
  const w=project.width, h=project.height, scale=Math.max(2, Math.min(16, Math.floor(avail/w)));
  const cls=$('grid').checked?'screen grid':'screen';
  stage.innerHTML='<div class="screen-wrap"><div class="'+cls+'" style="--cell:'+scale+'px" data-page="gif">'+
    '<img width="'+(w*scale)+'" height="'+(h*scale)+'"></div></div>';
  $('playbar').hidden=false; $('scrub').max=frames.length-1;
  wireHover(); showFrame(sel);
}
function showFrame(i){
  if(!frames.length) return;
  sel=Math.max(0, Math.min(frames.length-1, i));
  const img=document.querySelector('#stage .screen img'); if(img) img.src=frames[sel].dataUri;
  $('scrub').value=sel; $('framelbl').textContent=(sel+1)+' / '+frames.length;
  $('fdur').value=frames[sel].duration||'';
  document.querySelectorAll('.thumb').forEach((t,ix)=>t.classList.toggle('sel', ix===sel));
}
function wireHover(){
  const co=$('coords');
  document.querySelectorAll('#stage .screen img').forEach(img=>{
    img.onmousemove=e=>{const r=img.getBoundingClientRect();
      co.textContent='x '+Math.floor((e.clientX-r.left)/r.width*img.naturalWidth)+', y '+Math.floor((e.clientY-r.top)/r.height*img.naturalHeight); co.classList.add('live');};
    img.onmouseleave=()=>{co.textContent='x, y'; co.classList.remove('live');};
  });
}
function play(){
  if(!frames.length) return;
  playing=true; $('playbtn').innerHTML='&#10073;&#10073; Pause';
  const fps=parseInt($('fps').value,10)||8;
  const step=()=>{ showFrame((sel+1)%frames.length);
    const d=frames[sel].duration||Math.round(1000/fps); playTimer=setTimeout(step, Math.max(20,d)); };
  const d=frames[sel].duration||Math.round(1000/fps); playTimer=setTimeout(step, Math.max(20,d));
}
function stop(){ playing=false; clearTimeout(playTimer); $('playbtn').innerHTML='&#9654; Play'; }

async function api(url, body){
  const opt = body ? {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body)} : {method:'POST'};
  try{ return await (await fetch(url+'?'+gifQS(), opt)).json(); }catch(e){ return {ok:false,error:'Studio not reachable.'}; }
}
async function frameOp(op, index, extra){ stop(); const d=await api('frame-op', Object.assign({op,index},extra||{})); if(!d.ok){setStatus(d.error,'bad');return;} await openGif(cur); }
async function saveMeta(){ await api('save', {fps:parseInt($('fps').value,10)||8, loop:parseInt($('loop').value,10)||0, background:$('bg').value}); }

async function uploadFrames(fileList){
  const files=[...fileList].filter(f=>/\.png$/i.test(f.name)||f.type==='image/png');
  if(!files.length){ setStatus('Drop PNG files to add frames.','bad'); return; }
  if(!cur){ setStatus('Create or open a GIF first.','bad'); return; }
  setStatus('Adding '+files.length+' frame'+(files.length!==1?'s':'')+'…');
  const fd=new FormData(); files.forEach(f=>fd.append('file',f));
  let d; try{ d=await (await fetch('upload-frame?'+gifQS(),{method:'POST',body:fd})).json(); }catch(e){ setStatus('Upload failed.','bad'); return; }
  if(!d.ok){ setStatus(d.error,'bad'); return; }
  sel=frames.length; await openGif(cur); showFrame(frames.length-1); setStatus('Added '+d.added.length+' frame'+(d.added.length!==1?'s':'')+'.','ok');
}
async function exportGif(){
  if(!cur||!frames.length){ setStatus('Add a frame first.','bad'); return; }
  await saveMeta(); stop(); setStatus('Building GIF…');
  const d=await api('export');
  if(!d.ok){ setStatus(d.error||'Export failed.','bad'); $('exportmsg').textContent=d.error||''; return; }
  setStatus('Exported ✓','ok');
  $('exportmsg').innerHTML='Saved <b>'+esc(d.file)+'</b> ('+Math.round(d.bytes/1024)+' KB, '+d.frames+' frames). <a href="gif-file?'+gifQS()+'" download="'+esc(cur)+'.gif">Download again</a>';
  const a=document.createElement('a'); a.href='gif-file?'+gifQS(); a.download=cur+'.gif'; document.body.appendChild(a); a.click(); a.remove();
}

function slugify(s){return (s.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,''))||'my-gif';}
function openNew(){ $('newname').value=''; $('newwidth').value='192'; $('newerr').textContent=''; $('newslug').textContent='Folder: gifs/my-gif'; $('newmodal').hidden=false; $('newname').focus(); }
function closeNew(){ $('newmodal').hidden=true; }
async function createGif(){
  const name=$('newname').value.trim(); if(!name){ $('newerr').textContent='Give it a name first.'; return; }
  const d=await (await fetch('new',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({name, width:parseInt($('newwidth').value,10)})})).json();
  if(!d.ok){ $('newerr').textContent=d.error; return; }
  closeNew(); sel=0; await loadGifs(d.gif); setStatus('Created '+d.gif+'.','ok');
}

window.addEventListener('DOMContentLoaded', ()=>{
  $('newbtn').addEventListener('click', openNew);
  $('newcancel').addEventListener('click', closeNew);
  $('newok').addEventListener('click', createGif);
  $('newname').addEventListener('input', ()=>{ $('newslug').textContent='Folder: gifs/'+slugify($('newname').value||''); });
  $('newname').addEventListener('keydown', e=>{ if(e.key==='Enter') createGif(); });
  $('newmodal').addEventListener('click', e=>{ if(e.target===$('newmodal')) closeNew(); });
  document.addEventListener('keydown', e=>{ if(e.key==='Escape' && !$('newmodal').hidden) closeNew(); });

  $('exportbtn').addEventListener('click', exportGif);
  $('addblank').addEventListener('click', ()=>frameOp('blank',-1));
  $('copylast').addEventListener('click', ()=>frameOp('copy-last',-1));
  $('grid').addEventListener('change', buildStage);
  $('playbtn').addEventListener('click', ()=> playing?stop():play());
  $('scrub').addEventListener('input', ()=>{ stop(); showFrame(parseInt($('scrub').value,10)||0); });
  $('fps').addEventListener('change', saveMeta);
  $('loop').addEventListener('change', saveMeta);
  $('bg').addEventListener('change', saveMeta);
  $('fdur').addEventListener('change', ()=>{ if(frames[sel]) frameOp('duration', sel, {duration: parseInt($('fdur').value,10)||0}); });

  $('timeline').addEventListener('click', e=>{
    const b=e.target.closest('button[data-op]'); const thumb=e.target.closest('.thumb'); if(!thumb) return;
    const i=parseInt(thumb.dataset.i,10);
    if(b){ e.stopPropagation();
      if(b.dataset.op==='del') frameOp('delete',i);
      else if(b.dataset.op==='dup') frameOp('duplicate',i);
      else if(b.dataset.op==='move-l' && i>0) frameOp('move',i,{to:i-1});
      else if(b.dataset.op==='move-r' && i<frames.length-1) frameOp('move',i,{to:i+1});
      return; }
    stop(); showFrame(i);
  });

  // gif picker
  $('gifsel').addEventListener('change', ()=>{ if($('gifsel').value) openGif($('gifsel').value); });
  $('gifsel').addEventListener('focus', async ()=>{
    const d=await (await fetch('gifs.json')).json(); const m=$('gifmenu');
    m.innerHTML=(d.gifs||[]).map(g=>'<div class="appitem" data-g="'+esc(g)+'">'+esc(g)+'</div>').join('')||'<div class="appitem dim">No GIFs yet</div>';
    m.hidden=false;
  });
  $('gifmenu').addEventListener('mousedown', e=>{ const it=e.target.closest('[data-g]'); if(it){ openGif(it.dataset.g); } $('gifmenu').hidden=true; });
  $('gifsel').addEventListener('blur', ()=>setTimeout(()=>{$('gifmenu').hidden=true;}, 150));

  // drag-and-drop PNG frames
  let depth=0;
  ['dragenter','dragover'].forEach(ev=>document.addEventListener(ev,e=>{
    if(![...(e.dataTransfer?e.dataTransfer.types:[])].includes('Files')) return;
    e.preventDefault(); if(e.dataTransfer) e.dataTransfer.dropEffect='copy';
    if(ev==='dragenter'){ depth++; document.body.classList.add('dropping'); }
  }));
  document.addEventListener('dragleave', ()=>{ if(--depth<=0){ depth=0; document.body.classList.remove('dropping'); } });
  document.addEventListener('drop', e=>{
    if(![...(e.dataTransfer?e.dataTransfer.types:[])].includes('Files')) return;
    e.preventDefault(); depth=0; document.body.classList.remove('dropping');
    if(e.dataTransfer.files.length) uploadFrames(e.dataTransfer.files);
  });
  window.addEventListener('resize', ()=>{ if(frames.length) buildStage(); });

  loadGifs();
});
"""
