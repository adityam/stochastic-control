#!/usr/bin/env python3
"""Generate inventory DP tree SVGs for Lecture 2."""
from pathlib import Path

OUT = Path(__file__).parent / "svg"
OUT.mkdir(parents=True, exist_ok=True)

p, ch, cs = 1, 2, 5
actions = [5, 10]
demands = [5, 10]
prob = 0.5
s0 = 0

def h(s):
    return ch * s if s >= 0 else -cs * s

def step_cost(s, a, w):
    return p * a + h(s + a - w)

def Q2(s2):
    return {a: sum(prob * step_cost(s2, a, w) for w in demands) for a in actions}

def V2(s2):
    q = Q2(s2)
    a_opt = min(q, key=q.get)
    return q[a_opt], a_opt, q

def Q1(s1, a1):
    return sum(prob * (step_cost(s1, a1, w1) + V2(s1 + a1 - w1)[0]) for w1 in demands)

paths = []
for ai, a1 in enumerate(actions):
    for wi, w1 in enumerate(demands):
        s2 = s0 + a1 - w1
        v2, a2opt, q2 = V2(s2)
        paths.append({
            "id": f"p-a{a1}-w{w1}",
            "a1": a1, "w1": w1, "s2": s2,
            "ai": ai, "wi": wi,
            "y": [62, 138, 258, 334][ai * 2 + wi],
            "v2": v2, "a2opt": a2opt, "q2": q2,
        })

opt_a1 = min(actions, key=lambda a: Q1(s0, a))

# layout constants (match concordia scale ~1.35)
S = 1.35
W, H = 760 * S, 400 * S
sq, cr, tr = 10 * S, 6 * S, 2.5 * S
x_dec1, x_chance1, x_dec2, x_chance2, x_term = (
    24 * S, 130 * S, 292 * S, 430 * S, 560 * S
)
row_ys = [y * S for y in [62, 138, 258, 334]]
term_dy2, term_dy_w = 16 * S, 16 * 1.1 * S
fs, fs_pay = 9 * S, 9 * S
sw_main, sw_thin = 1.15 * S, 0.9 * S
bg = "#ffffff"

def edge_label(x, y, text):
    w = len(text) * (5.5 * S) + 10 * S
    h = 16 * S
    return (
        f'<rect x="{x - w/2}" y="{y - h/2}" width="{w}" height="{h}" fill="{bg}" rx="2"/>'
        f'<text x="{x}" y="{y + 4*S}" text-anchor="middle" font-size="{fs}" fill="#212529">{text}</text>'
    )

def legend():
    g = 8 * S
    return f'''<g transform="translate({8*S},{8*S})" font-size="{fs}" fill="#495057">
    <rect x="0" y="0" width="{9*S}" height="{9*S}" fill="{bg}" stroke="#0d6efd" stroke-width="{1.35*S}"/>
    <text x="{14*S}" y="{9*S}">decision</text>
    <circle cx="{90*S}" cy="{4.5*S}" r="{4.5*S}" fill="{bg}" stroke="#198754" stroke-width="{1.35*S}"/>
    <text x="{100*S}" y="{9*S}">chance</text>
  </g>'''

def header():
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}"
  font-family="'Latin Modern Math','STIX Two Math','Times New Roman',serif">
  <style>
    .edge {{ stroke:#6c757d; stroke-width:{sw_main}; fill:none; stroke-linecap:round; }}
    .thin {{ stroke:#adb5bd; stroke-width:{sw_thin}; fill:none; }}
    .dec  {{ fill:{bg}; stroke:#0d6efd; stroke-width:{1.35*S}; }}
    .ch   {{ fill:{bg}; stroke:#198754; stroke-width:{1.35*S}; }}
    .term {{ fill:{bg}; stroke:#adb5bd; stroke-width:{sw_thin}; }}
    .shade {{ fill:rgba(25,135,84,0.18); stroke:none; }}
    .hi   {{ fill:#fff59d; stroke:#212529; stroke-width:{1.35*S}; }}
  </style>'''

def period1(parts, highlight_a1=None, show_v2=False):
    mid_y = (row_ys[0] + row_ys[3]) / 2
    parts.append(
        f'<rect class="dec" x="{x_dec1-sq/2}" y="{mid_y-sq/2}" width="{sq}" height="{sq}"/>'
    )
    parts.append(
        f'<text x="{x_dec1}" y="{mid_y-sq/2-5*S}" text-anchor="middle" font-size="{fs}" fill="#6c757d">S&#8321;=0</text>'
    )
    for ai, a1 in enumerate(actions):
        p1 = [p for p in paths if p["a1"] == a1]
        y0 = (p1[0]["y"] + p1[1]["y"]) / 2
        hi = highlight_a1 is not None and a1 == highlight_a1
        stroke = "#212529" if hi else "#6c757d"
        sw = sw_main * (1.4 if hi else 1)
        parts.append(
            f'<line class="edge" x1="{x_dec1}" y1="{mid_y}" x2="{x_chance1}" y2="{y0}" stroke="{stroke}" stroke-width="{sw}"/>'
        )
        parts.append(edge_label((x_dec1 + x_chance1) / 2, (mid_y + y0) / 2 - 2 * S, f"a={a1}"))
        parts.append(f'<circle class="ch" cx="{x_chance1}" cy="{y0}" r="{cr}"/>')
        for path in p1:
            parts.append(
                f'<line class="thin" x1="{x_chance1}" y1="{y0}" x2="{x_dec2}" y2="{path["y"]}" />'
            )
            parts.append(
                edge_label((x_chance1 + x_dec2) / 2, (y0 + path["y"]) / 2, f"w={path['w1']}")
            )

def dec2_node(path, show_v2=False, highlight=False):
    x, y = x_dec2, path["y"]
    cls = "hi" if highlight else "dec"
    lbl = ""
    if show_v2:
        lbl = (
            f'<text x="{x+sq/2+8*S}" y="{y-1*S}" font-size="{fs}" fill="#6c757d">S&#8322;={path["s2"]}</text>'
            f'<text x="{x+sq/2+8*S}" y="{y+10*S}" font-size="{fs_pay}" fill="#212529" font-weight="500">V&#8322;={path["v2"]}</text>'
        )
    else:
        lbl = f'<text x="{x}" y="{y+sq/2+10*S}" text-anchor="middle" font-size="{fs}" fill="#6c757d">S&#8322;={path["s2"]}</text>'
    return (
        f'<rect class="{cls}" x="{x-sq/2}" y="{y-sq/2}" width="{sq}" height="{sq}"/>'
        + lbl
    )

def period2(path, parts, mode="full"):
    y_from = path["y"]
    s2 = path["s2"]
    q2 = path["q2"]
    a2opt = path["a2opt"]
    for a2i, a2 in enumerate(actions):
        y0 = y_from + (a2i - 0.5) * term_dy2 * 2.2
        hi = mode in ("q2opt", "policy") and a2 == a2opt
        stroke = "#212529" if hi else "#6c757d"
        sw = sw_main * (1.4 if hi else 1)
        parts.append(
            f'<line x1="{x_dec2}" y1="{y_from}" x2="{x_chance2}" y2="{y0}" stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round"/>'
        )
        parts.append(edge_label((x_dec2 + x_chance2) / 2, (y_from + y0) / 2 - 2 * S, f"a={a2}"))
        if mode in ("q2", "q2opt", "policy"):
            parts.append(
                f'<text x="{x_chance2+10*S}" y="{y0+3.5*S}" font-size="{fs_pay}" fill="#212529" font-weight="500">Q&#8322;={q2[a2]}</text>'
            )
            continue
        parts.append(f'<circle class="ch" cx="{x_chance2}" cy="{y0}" r="{cr}"/>')
        for wi, w2 in enumerate(demands):
            yt = y0 + (wi - 0.5) * term_dy_w
            parts.append(f'<line class="thin" x1="{x_chance2}" y1="{y0}" x2="{x_term}" y2="{yt}"/>')
            parts.append(edge_label((x_chance2 + x_term) / 2, (y0 + yt) / 2, f"w={w2}"))
            parts.append(f'<circle class="term" cx="{x_term}" cy="{yt}" r="{tr}"/>')
            c2 = step_cost(s2, a2, w2)
            parts.append(
                f'<text x="{x_term+6*S}" y="{yt+3*S}" font-size="{fs_pay}" fill="#212529">c&#8322;={c2}</text>'
            )

def build(mode):
    parts = []
    period1(parts, highlight_a1=opt_a1 if mode == "policy" else None,
            show_v2=mode in ("v2", "collapse1q", "collapse1opt", "policy"))
    show_p2 = mode in ("full", "shade2", "q2", "q2opt", "policy", "statespace")
    collapsed_p2 = mode in ("v2", "collapse1q", "collapse1opt", "policy")
    for path in paths:
        parts.append(dec2_node(path, show_v2=collapsed_p2,
                               highlight=mode == "statespace" and path["s2"] == 0))
        if show_p2 and not collapsed_p2:
            period2(path, parts, mode=mode if mode in ("q2", "q2opt", "policy") else "full")
    if mode == "collapse1q":
        mid_y = (row_ys[0] + row_ys[3]) / 2
        for a1 in actions:
            p1 = [p for p in paths if p["a1"] == a1]
            y0 = (p1[0]["y"] + p1[1]["y"]) / 2
            parts.append(
                f'<text x="{x_chance1+18*S}" y="{y0+3.5*S}" font-size="{fs_pay}" fill="#212529" font-weight="500">Q&#8321;={Q1(s0,a1)}</text>'
            )
    return header() + "\n" + "\n".join(parts) + "\n" + legend() + "\n</svg>"

for name, mode in [
    ("inventory-tree-full", "full"),
    ("inventory-tree-q2", "q2"),
    ("inventory-tree-q2opt", "q2opt"),
    ("inventory-tree-v2", "v2"),
    ("inventory-tree-collapse1q", "collapse1q"),
    ("inventory-tree-policy", "policy"),
    ("inventory-tree-statespace", "statespace"),
]:
    (OUT / f"{name}.svg").write_text(build(mode))
    print("wrote", name)
