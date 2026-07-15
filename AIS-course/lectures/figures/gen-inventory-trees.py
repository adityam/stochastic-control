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

# layout constants — leaf-driven so period-2 fans are uniform and non-overlapping
S = 1.35
X = 0.75                 # compress horizontal spacing (figures were too wide)
sq, cr, tr = 10 * S, 6 * S, 2.5 * S
x_dec1, x_chance1, x_dec2, x_chance2, x_term = (
    x * S * X for x in (36, 150, 320, 540, 760)
)
# 16 terminal leaves: 4 equal clusters of 4 (a2×w2), equal inter-cluster gaps
leaf_pitch = 40          # unscaled; label boxes are ~16 tall
cluster_gap = 36         # extra space between S2 clusters (same for all → symmetric)
pad_top, pad_bot = 56, 40
leaf_ys = []
_y = pad_top
for _c in range(4):
    for _j in range(4):
        leaf_ys.append(_y * S)
        _y += leaf_pitch
    _y += cluster_gap
W = 980 * S * X
H = (pad_top + 16 * leaf_pitch + 3 * cluster_gap + pad_bot) * S
# S2 decision-node y = midpoint of its four leaves
base_ys = [
    (leaf_ys[4 * k] + leaf_ys[4 * k + 3]) / 2 for k in range(4)
]
fs, fs_pay = 9 * S, 9 * S
fs_node = fs * 1.25          # S_t / V / Q / c labels at nodes
sw_main, sw_thin = 1.15 * S, 0.9 * S
sw_node = 1.35 * S
sw_chance = sw_node * 1.5
bg = "#ffffff"
ink = "#000000"
dec_stroke = "#0d6efd"
ch_stroke = "#198754"

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
        v2_stage, a2opt_stage, q2_stage = V2(s2)
        c1 = step_cost(s0, a1, w1)
        # Q2 / V2 from total path cost C (includes sunk first-stage cost)
        q2 = {
            a: c1 + sum(prob * step_cost(s2, a, w) for w in demands) for a in actions
        }
        a2opt = min(q2, key=q2.get)
        v2 = q2[a2opt]
        paths.append({
            "id": f"p-a{a1}-w{w1}",
            "a1": a1, "w1": w1, "s2": s2,
            "ai": ai, "wi": wi,
            "y": base_ys[ai * 2 + wi],
            "v2": v2, "a2opt": a2opt, "q2": q2,
            "c1": c1,
            "v2_stage": v2_stage, "a2opt_stage": a2opt_stage, "q2_stage": q2_stage,
        })

def Q1_total(a1):
    return sum(prob * next(p["v2"] for p in paths if p["a1"] == a1 and p["w1"] == w1) for w1 in demands)

opt_a1 = min(actions, key=Q1_total)
def edge_label(x, y, text, highlight=False):
    w = len(text) * (5.5 * S) + 10 * S
    h = 16 * S
    if highlight:
        rect = (
            f'<rect class="hi" x="{x - w/2}" y="{y - h/2}" width="{w}" height="{h}" rx="2"/>'
        )
    else:
        rect = (
            f'<rect x="{x - w/2}" y="{y - h/2}" width="{w}" height="{h}" fill="{bg}" rx="2"/>'
        )
    return (
        rect
        + f'<text x="{x}" y="{y + 4*S}" text-anchor="middle" font-size="{fs}" fill="#212529">{text}</text>'
    )

def header(w=None, h=None):
    w = W if w is None else w
    h = H if h is None else h
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}"
  font-family="'Latin Modern Math','STIX Two Math','Times New Roman',serif">
  <style>
    .edge {{ stroke:{ink}; stroke-width:{sw_main}; fill:none; stroke-linecap:round; }}
    .edge-hi {{ stroke:#e6b422; stroke-width:{sw_main * 2.2}; fill:none; stroke-linecap:round; }}
    .thin {{ stroke:{ink}; stroke-width:{sw_thin}; fill:none; }}
    .dec  {{ fill:{bg}; stroke:{dec_stroke}; stroke-width:{sw_node}; }}
    .ch   {{ fill:{bg}; stroke:{ch_stroke}; stroke-width:{sw_chance}; }}
    .term {{ fill:{bg}; stroke:#adb5bd; stroke-width:{sw_thin}; }}
    .shade {{ fill:rgba(25,135,84,0.18); stroke:none; }}
    .hi   {{ fill:#fff59d; stroke:#212529; stroke-width:1.6; }}
  </style>'''

def period1(edges, nodes, labels, highlight_a1=None, show_s=True, fold_w1=False):
    """If fold_w1, stop at the A1-chance nodes (no W1 edges to period-2 decisions)."""
    mid_y = (base_ys[0] + base_ys[3]) / 2
    nodes.append(
        f'<rect class="dec" x="{x_dec1-sq/2}" y="{mid_y-sq/2}" width="{sq}" height="{sq}"/>'
    )
    if show_s:
        labels.append(
            f'<text x="{x_dec1}" y="{mid_y-sq/2-5*S}" text-anchor="middle" font-size="{fs_node}" fill="#6c757d">S&#8321;=0</text>'
        )
    for ai, a1 in enumerate(actions):
        p1 = [p for p in paths if p["a1"] == a1]
        y0 = (p1[0]["y"] + p1[1]["y"]) / 2
        hi = highlight_a1 is not None and a1 == highlight_a1
        cls = "edge-hi" if hi else "edge"
        edges.append(
            f'<line class="{cls}" x1="{x_dec1}" y1="{mid_y}" x2="{x_chance1}" y2="{y0}"/>'
        )
        labels.append(
            edge_label(
                (x_dec1 + x_chance1) / 2, (mid_y + y0) / 2 - 2 * S, f"a={a1}",
                highlight=hi,
            )
        )
        nodes.append(f'<circle class="ch" cx="{x_chance1}" cy="{y0}" r="{cr}"/>')
        if fold_w1:
            continue
        for path in p1:
            edges.append(
                f'<line class="thin" x1="{x_chance1}" y1="{y0}" x2="{x_dec2}" y2="{path["y"]}" />'
            )
            labels.append(
                edge_label((x_chance1 + x_dec2) / 2, (y0 + path["y"]) / 2, f"w={path['w1']}")
            )

def dec2_node(path, show_v2=False, highlight=False, show_s=True):
    x, y = x_dec2, path["y"]
    cls = "hi" if highlight else "dec"
    parts = []
    if show_v2:
        v2 = path["v2"]
        v2_txt = f"{v2:g}" if isinstance(v2, float) else str(v2)
        if show_s:
            parts.append(
                f'<text x="{x+sq/2+8*S}" y="{y-1*S}" font-size="{fs_node}" fill="#6c757d">S&#8322;={path["s2"]}</text>'
            )
            parts.append(
                f'<text x="{x+sq/2+8*S}" y="{y+12*S}" font-size="{fs_node}" fill="#212529" font-weight="500">V⋆&#8322;={v2_txt}</text>'
            )
        else:
            parts.append(
                f'<text x="{x+sq/2+8*S}" y="{y+3.5*S}" font-size="{fs_node}" fill="#212529" font-weight="500">V⋆&#8322;={v2_txt}</text>'
            )
    elif show_s:
        parts.append(
            f'<text x="{x}" y="{y+sq/2+12*S}" text-anchor="middle" font-size="{fs_node}" fill="#6c757d">S&#8322;={path["s2"]}</text>'
        )
    node = f'<rect class="{cls}" x="{x-sq/2}" y="{y-sq/2}" width="{sq}" height="{sq}"/>'
    return node, "".join(parts)

def period2(path, edges, nodes, labels, mode="full"):
    y_from = path["y"]
    s2 = path["s2"]
    q2 = path["q2"]
    a2opt = path["a2opt"]
    path_idx = path["ai"] * 2 + path["wi"]
    for a2i, a2 in enumerate(actions):
        i0 = 4 * path_idx + 2 * a2i
        yt0, yt1 = leaf_ys[i0], leaf_ys[i0 + 1]
        y0 = (yt0 + yt1) / 2
        hi = mode == "policy" and a2 == a2opt
        cls = "edge-hi" if hi else "edge"
        edges.append(
            f'<line class="{cls}" x1="{x_dec2}" y1="{y_from}" x2="{x_chance2}" y2="{y0}"/>'
        )
        labels.append(
            edge_label(
                (x_dec2 + x_chance2) / 2, (y_from + y0) / 2 - 2 * S, f"a={a2}",
                highlight=hi,
            )
        )
        nodes.append(f'<circle class="ch" cx="{x_chance2}" cy="{y0}" r="{cr}"/>')
        if mode == "full_q2":
            labels.append(
                f'<text x="{x_chance2+10*S}" y="{y0+3.5*S}" font-size="{fs_node}" fill="#212529" font-weight="500">Q⋆&#8322;={q2[a2]:g}</text>'
            )
            # fold the W2 fan: chance node carries Q2 = E[C | h2, a2]
            continue
        for wi, w2 in enumerate(demands):
            yt = leaf_ys[i0 + wi]
            edges.append(f'<line class="thin" x1="{x_chance2}" y1="{y0}" x2="{x_term}" y2="{yt}"/>')
            lx = x_chance2 + 0.32 * (x_term - x_chance2)
            ly = y0 + 0.32 * (yt - y0)
            labels.append(edge_label(lx, ly, f"w={w2}"))
            nodes.append(f'<circle class="term" cx="{x_term}" cy="{yt}" r="{tr}"/>')
            c_total = path["c1"] + step_cost(s2, a2, w2)
            labels.append(
                f'<text x="{x_term+10*S}" y="{yt+3.5*S}" font-size="{fs_node}" fill="#212529">C={c_total}</text>'
            )

# Lecture DP figures (no S_t); statespace keeps S_t.
MODES_WITHOUT_S = {
    "full", "full_q2", "full_v2", "full_q1", "full_v1", "policy",
}

def build(mode):
    edges, nodes, labels = [], [], []
    show_s = mode not in MODES_WITHOUT_S

    if mode == "full_v1":
        # fully folded at the root — compact canvas
        Wv1, Hv1 = 220 * S * X, 120 * S
        x0, y0 = Wv1 / 2, Hv1 / 2
        nodes.append(
            f'<rect class="dec" x="{x0-sq/2}" y="{y0-sq/2}" width="{sq}" height="{sq}"/>'
        )
        labels.append(
            f'<text x="{x0+sq/2+8*S}" y="{y0+3.5*S}" font-size="{fs_node}" fill="#212529" font-weight="500">V⋆&#8321;={Q1_total(opt_a1):g}</text>'
        )
        parts = edges + labels + nodes
        return (
            f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {Wv1} {Hv1}" width="{Wv1}" height="{Hv1}"
  font-family="'Latin Modern Math','STIX Two Math','Times New Roman',serif">
  <style>
    .dec  {{ fill:{bg}; stroke:{dec_stroke}; stroke-width:{sw_node}; }}
  </style>
'''
            + "\n".join(parts)
            + "\n</svg>"
        )

    if mode == "full_q1":
        # fold W1: only root, A1, and Q1 at chance nodes — compact layout
        Hq1 = 280 * S
        y_ch = [Hq1 * 0.28, Hq1 * 0.72]
        mid_y = Hq1 / 2
        nodes.append(
            f'<rect class="dec" x="{x_dec1-sq/2}" y="{mid_y-sq/2}" width="{sq}" height="{sq}"/>'
        )
        for ai, a1 in enumerate(actions):
            y0 = y_ch[ai]
            edges.append(
                f'<line class="edge" x1="{x_dec1}" y1="{mid_y}" x2="{x_chance1}" y2="{y0}"/>'
            )
            labels.append(edge_label((x_dec1 + x_chance1) / 2, (mid_y + y0) / 2 - 2 * S, f"a={a1}"))
            nodes.append(f'<circle class="ch" cx="{x_chance1}" cy="{y0}" r="{cr}"/>')
            labels.append(
                f'<text x="{x_chance1+10*S}" y="{y0+3.5*S}" font-size="{fs_node}" fill="#212529" font-weight="500">Q⋆&#8321;={Q1_total(a1):g}</text>'
            )
        Wq1 = x_chance1 + 120 * S
        parts = edges + labels + nodes
        return (
            f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {Wq1} {Hq1}" width="{Wq1}" height="{Hq1}"
  font-family="'Latin Modern Math','STIX Two Math','Times New Roman',serif">
  <style>
    .edge {{ stroke:{ink}; stroke-width:{sw_main}; fill:none; stroke-linecap:round; }}
    .dec  {{ fill:{bg}; stroke:{dec_stroke}; stroke-width:{sw_node}; }}
    .ch   {{ fill:{bg}; stroke:{ch_stroke}; stroke-width:{sw_chance}; }}
  </style>
'''
            + "\n".join(parts)
            + "\n</svg>"
        )

    period1(
        edges, nodes, labels,
        highlight_a1=opt_a1 if mode == "policy" else None,
        show_s=show_s,
        fold_w1=False,
    )

    show_p2 = mode in ("full", "full_q2", "policy", "statespace")
    collapsed_p2 = mode == "full_v2"
    for path in paths:
        node, lbl = dec2_node(
            path,
            show_v2=collapsed_p2,
            highlight=mode == "statespace" and path["s2"] == 0,
            show_s=show_s,
        )
        nodes.append(node)
        labels.append(lbl)
        if show_p2 and not collapsed_p2:
            period2(
                path, edges, nodes, labels,
                mode=mode if mode in ("policy", "full_q2") else "full",
            )

    parts = edges + labels + nodes
    return header() + "\n" + "\n".join(parts) + "\n</svg>"

for name, mode in [
    ("inventory-tree-full", "full"),
    ("inventory-tree-full-Q2", "full_q2"),
    ("inventory-tree-full-V2", "full_v2"),
    ("inventory-tree-full-Q1", "full_q1"),
    ("inventory-tree-full-V1", "full_v1"),
    ("inventory-tree-policy", "policy"),
    ("inventory-tree-statespace", "statespace"),
]:
    (OUT / f"{name}.svg").write_text(build(mode))
    print("wrote", name)
