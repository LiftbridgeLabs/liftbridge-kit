// The gallery page. __DATA__ is replaced with the themes as JSON and
// __COUNT__ with how many there are.
let template = #"""
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Theme Gallery</title>
<style>
  :root {
    --page: #f2f2f4; --panel: #ffffff; --text: #1c1c1e; --soft: #6b6b70; --line: #dcdce0; --pick: #1c1c1e;
    color-scheme: light dark;
  }
  @media (prefers-color-scheme: dark) {
    :root { --page: #111113; --panel: #1c1c1f; --text: #f2f2f4; --soft: #a0a0a8; --line: #333338; --pick: #f2f2f4; }
  }
  * { box-sizing: border-box; }
  body { margin: 0; background: var(--page); color: var(--text);
         font: 15px/1.4 -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", sans-serif; }
  header { position: sticky; top: 0; z-index: 2; background: var(--page); border-bottom: 1px solid var(--line);
           padding: 14px 16px; display: flex; flex-wrap: wrap; gap: 10px 16px; align-items: center; }
  h1 { font-size: 20px; margin: 0; }
  .count { color: var(--soft); }
  .modes { display: flex; gap: 6px; margin-left: auto; }
  .modes button { font: inherit; font-weight: 600; padding: 6px 12px; border-radius: 8px; cursor: pointer;
                  border: 1px solid var(--line); background: var(--panel); color: var(--text); }
  .modes button[aria-pressed="true"] { border: 2px solid var(--pick); padding: 5px 11px; }
  main { padding: 8px 16px 40px; max-width: 1400px; margin: 0 auto; }
  h2 { font-size: 18px; margin: 26px 0 10px; display: flex; gap: 8px; align-items: center; }
  .season { font-size: 12px; font-weight: 600; color: var(--soft); border: 1px solid var(--line);
            border-radius: 99px; padding: 2px 8px; }
  .grid { display: grid; gap: 12px; grid-template-columns: repeat(auto-fill, minmax(min(var(--card, 460px), 100%), 1fr)); }
  .theme { background: var(--panel); border: 1px solid var(--line); border-radius: 14px; padding: 12px; min-width: 0; }
  .title { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
  .dot { width: 28px; height: 28px; border-radius: 50%; flex: none; box-shadow: inset 0 0 0 1px rgba(0,0,0,.12); }
  .name { font-weight: 700; }
  .id { color: var(--soft); font: 12px ui-monospace, SFMono-Regular, Menlo, monospace; }
  .shots { display: grid; gap: 8px; grid-template-columns: repeat(auto-fit, minmax(132px, 1fr)); }
  .label { font-size: 11px; font-weight: 600; color: var(--soft); text-transform: uppercase; letter-spacing: .04em; margin-bottom: 4px; }
  .screen { border-radius: 10px; padding: 8px; display: flex; flex-direction: column; gap: 6px; min-height: 128px; overflow: hidden; }
  .card { border-radius: 8px; padding: 7px 8px; border: 1px solid; }
  .card b { display: block; font-size: 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .card span { display: block; font-size: 11px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .row { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
  .chip { font-size: 11px; font-weight: 600; border-radius: 99px; padding: 2px 8px; }
  .button { margin-left: auto; font-size: 11px; font-weight: 700; border-radius: 6px; padding: 3px 8px; }
  .check { width: 14px; height: 14px; border-radius: 50%; flex: none; }
  .hex { display: flex; flex-wrap: wrap; gap: 4px; margin-top: 6px; }
  .hex button { font: 11px ui-monospace, SFMono-Regular, Menlo, monospace; display: inline-flex; gap: 4px; align-items: center;
                border: 1px solid var(--line); background: none; color: var(--soft); border-radius: 6px; padding: 1px 5px; cursor: pointer; }
  .hex i { width: 9px; height: 9px; border-radius: 2px; box-shadow: inset 0 0 0 1px rgba(127,127,127,.4); }
  footer { color: var(--soft); font-size: 13px; padding: 0 16px 30px; max-width: 1400px; margin: 0 auto; }
  @media (max-width: 520px) { .modes { margin-left: 0; } }
</style>
</head>
<body>
<header>
  <h1>Theme Gallery</h1>
  <span class="count">__COUNT__ themes</span>
  <div class="modes" role="group" aria-label="Modes to show">
    <button data-mode="all" aria-pressed="true">All</button>
    <button data-mode="light" aria-pressed="false">Light</button>
    <button data-mode="dark" aria-pressed="false">Dark</button>
    <button data-mode="black" aria-pressed="false">Black</button>
  </div>
</header>
<main id="groups"></main>
<footer>Each preview uses the theme's real colors: background, a card with main and secondary text, a tag, the accent button and the "done" color. Tap a color code to copy it. Seasonal groups show in apps only during their dates.</footer>
<script>
const groups = __DATA__;
const names = { light: "Light", dark: "Dark", black: "Black" };
let shown = ["light", "dark", "black"];

function el(tag, cls, text) {
  const node = document.createElement(tag);
  if (cls) node.className = cls;
  if (text != null) node.textContent = text;
  return node;
}

function screen(c) {
  const s = el("div", "screen");
  s.style.background = c.canvas;
  const card = el("div", "card");
  card.style.background = c.card; card.style.borderColor = c.hairline;
  const title = el("b", null, "Lemon chicken"); title.style.color = c.ink;
  const sub = el("span", null, "35 min · serves 4"); sub.style.color = c.muted;
  card.append(title, sub);
  const row = el("div", "row");
  const chip = el("span", "chip", "Dinner"); chip.style.background = c.chip; chip.style.color = c.ink;
  const check = el("span", "check"); check.style.background = c.success; check.title = "Done color";
  const button = el("span", "button", "Start"); button.style.background = c.accent; button.style.color = c.onAccent;
  row.append(chip, check, button);
  const link = el("span", "chip", "Link text"); link.style.color = c.accent; link.style.padding = "0";
  s.append(card, row, link);
  return s;
}

function hexes(c) {
  const box = el("div", "hex");
  for (const role of ["accent", "canvas", "card", "chip", "ink"]) {
    const b = el("button");
    b.title = role + ": tap to copy";
    const sw = el("i"); sw.style.background = c[role];
    b.append(sw, document.createTextNode(c[role].slice(1)));
    b.addEventListener("click", () => { try { navigator.clipboard.writeText(c[role]); } catch (e) {} });
    box.append(b);
  }
  return box;
}

function render() {
  const root = document.getElementById("groups");
  // Wider cards when all three modes sit side by side.
  root.style.setProperty("--card", shown.length > 1 ? "460px" : "260px");
  root.replaceChildren();
  const dark = matchMedia("(prefers-color-scheme: dark)").matches;
  for (const g of groups) {
    const h = el("h2", null, g.title);
    if (g.season) h.append(el("span", "season", g.season));
    const grid = el("div", "grid");
    for (const t of g.themes) {
      const card = el("div", "theme");
      const head = el("div", "title");
      const dot = el("span", "dot");
      const sw = dark ? t.swatch.dark : t.swatch.light;
      dot.style.background = `linear-gradient(135deg, ${sw[0]}, ${sw[1]})`;
      const text = el("div");
      text.append(el("div", "name", t.name), el("div", "id", t.id));
      head.append(dot, text);
      const shots = el("div", "shots");
      for (const m of shown) {
        const col = el("div");
        col.append(el("div", "label", names[m]), screen(t[m]), hexes(t[m]));
        shots.append(col);
      }
      card.append(head, shots);
      grid.append(card);
    }
    root.append(h, grid);
  }
}

document.querySelectorAll(".modes button").forEach(b => b.addEventListener("click", () => {
  document.querySelectorAll(".modes button").forEach(x => x.setAttribute("aria-pressed", x === b));
  shown = b.dataset.mode === "all" ? ["light", "dark", "black"] : [b.dataset.mode];
  render();
}));
matchMedia("(prefers-color-scheme: dark)").addEventListener("change", render);
render();
</script>
</body>
</html>
"""#
