"""One-time, deterministic main.gd component extraction."""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1]
path = root / "game/ui/main.gd"
source = path.read_text(encoding="utf-8")

def take(start, end):
    global source
    a = source.index(start)
    b = source.index(end, a)
    chunk = source[a:b]
    source = source[:a] + source[b:]
    return chunk.strip("\n") + "\n\n"

def prefix(code, names):
    # Split at quoted strings, including escaped quotes: only code is rewritten.
    parts = re.split(r'("(?:\\.|[^"\\])*")', code)
    pattern = re.compile(r'(?<![\w.])(' + '|'.join(map(re.escape, sorted(names, key=len, reverse=True))) + r')\b')
    return ''.join(part if i % 2 else pattern.sub(lambda m: 'host.' + m.group(1), part)
                   for i, part in enumerate(parts))

fields = set(re.findall(r'^var (_\w+)', source, re.M))
main_funcs = set(re.findall(r'^func (_\w+)\(', source, re.M))

if sys.argv[1] == "agenda":
    advice = take('## İlk haftalarda yeni oyuncuya kısa yol gösterme', 'var _stage:')
    guide = take('## İlk haftaların yol göstericisi', 'func _fact_act(')
    methods = take('func _pill(', 'func _rebuild_cards(')
    moved = set(re.findall(r'^func (_\w+)\(', guide + methods, re.M))
    # The person card also calls _short_name; retain that name on main.
    wrappers = {'_rebuild_facts': '() -> void', '_rebuild_agenda': '() -> void',
                '_short_name': '(full: String) -> String'}
    for name, sig in wrappers.items():
        if name == '_short_name':
            source += '\nfunc _short_name(full: String) -> String:\n\treturn _agenda_view._short_name(full)\n'
        else:
            source += f'\nfunc {name}{sig}:\n\t_agenda_view.{name}()\n'
    main_funcs -= moved
    code = prefix(guide + methods, fields | main_funcs)
    code = code.replace('TIPS[kind[0]]', 'host._action_tip(kind[0])')
    code = code.replace('host._sel = [sid]', 'host._sel.clear()\n\t\t\t\thost._sel.append(sid)')
    for old, new in {
        'var keep_scroll := host._scroll.scroll_vertical': 'var keep_scroll: int = host._scroll.scroll_vertical',
        'var ic_tex := host._art(': 'var ic_tex: Texture2D = host._art(',
        'var tex := host._event_art(': 'var tex: Texture2D = host._event_art(',
        'var por := host._initial_art(': 'var por: Control = host._initial_art(',
    }.items():
        code = code.replace(old, new)
    component = 'extends RefCounted\n\nconst UIKit := preload("res://game/ui/ui_kit.gd")\n\nvar host: Control\n\nfunc _init(main: Control) -> void:\n\thost = main\n\n' + advice + code
    (root / 'game/ui/agenda_view.gd').write_text(component, encoding='utf-8')
    source = source.replace('const MODAL := preload("res://game/ui/modal.gd")', 'const MODAL := preload("res://game/ui/modal.gd")\nconst AGENDA_VIEW := preload("res://game/ui/agenda_view.gd")')
    source = source.replace('var _stage: Control', 'var _agenda_view: RefCounted\nvar _stage: Control')
    source = source.replace('\t_build_ui()\n', '\t_agenda_view = AGENDA_VIEW.new(self)\n\t_build_ui()\n', 1)
    source += '\nfunc _action_tip(key: String) -> String:\n\treturn TIPS[key]\n'
elif sys.argv[1] == "person":
    constants = take('const ROLE := {', 'var _agenda_view: RefCounted')
    hint_default = take('const HINT_DEFAULT :=', 'var _busy :=')
    ui = take('\t# Sağ: kişiler ve eylemler', '\t# Alt satır: haftanın akış şeridi')
    controls = take('func _show_act_cat(', 'func _toast_msg(')
    cards = take('func _rebuild_cards()', 'func _headline_items()')
    moved = set(re.findall(r'^func (_\w+)\(', controls + cards, re.M))
    moved |= {'_build_person_panel'}
    main_funcs -= moved
    # Keep public entry points for autoplay, screenshots and main's own callbacks.
    signatures = {
        '_show_act_cat': '(cat: String) -> void', '_add_btn': '(parent: Node, key: String, text: String, cb: Callable) -> void',
        '_preview': '(key: String) -> void', '_hint': '(text: String) -> void',
        '_rebuild_cards': '() -> void', '_card_fade': '() -> Texture2D',
        '_make_card': '(a) -> PanelContainer', '_on_card_input': '(ev: InputEvent, id: String) -> void',
        '_style_cards': '(hover_id := "") -> void', '_update_action_states': '() -> void',
        '_update_info': '() -> void', '_signs_tip': '(a) -> String',
        '_trait': '(text: String, col: Color, filled := -1, total := 0, tip := "") -> Control',
    }
    # Preserve the lazy texture cache on the component rather than main.
    source = source.replace('\t# Alt satır: haftanın akış şeridi', '\t_build_person_panel(cols)\n\n\t# Alt satır: haftanın akış şeridi', 1)
    source += '\nfunc _build_person_panel(cols: HBoxContainer) -> void:\n\t_person_panel._build_ui(cols)\n'
    for name, sig in signatures.items():
        args = {'_show_act_cat': 'cat', '_add_btn': 'parent, key, text, cb', '_preview': 'key', '_hint': 'text',
                '_make_card': 'a', '_on_card_input': 'ev, id', '_style_cards': 'hover_id', '_signs_tip': 'a',
                '_trait': 'text, col, filled, total, tip'}.get(name, '')
        call = f'_person_panel.{name}({args})'
        ret = 'return ' if '-> void' not in sig else ''
        source += f'\nfunc {name}{sig}:\n\t{ret}{call}\n'
    fields.discard('_card_fade_tex')
    code = prefix(controls + cards, fields | main_funcs)
    code = code.replace('host._sel = [id]', 'host._sel.clear()\n\t\thost._sel.append(id)')
    # _build_ui body is indented one tab deeper than a method body already.
    ui_code = prefix(ui, fields | main_funcs)
    ui_code = ui_code.replace('var cap := host._section(', 'var cap: Control = host._section(')
    for old, new in {
        'var id := host._selected_primary()': 'var id: String = host._selected_primary()',
        'var n := host._sel.size()': 'var n: int = host._sel.size()',
        'var card_art := host._initial_art(': 'var card_art: Control = host._initial_art(',
        'var selected := host._sel.has(id)': 'var selected: bool = host._sel.has(id)',
        'var off := busy or id == ""': 'var off: bool = busy or id == ""',
        'var art := host._initial_art(': 'var art: Control = host._initial_art(',
    }.items():
        code = code.replace(old, new)
    component = ('extends RefCounted\n\nconst UIKit := preload("res://game/ui/ui_kit.gd")\n\nvar host: Control\n\n'
                 + constants + hint_default + '\nfunc _init(main: Control) -> void:\n\thost = main\n\n'
                 + 'func _build_ui(cols: HBoxContainer) -> void:\n' + ui_code + '\n' + code)
    component += '\nfunc _action_tip(key: String) -> String:\n\treturn TIPS[key]\n'
    (root / 'game/ui/person_panel.gd').write_text(component, encoding='utf-8')
    source = source.replace('const AGENDA_VIEW := preload("res://game/ui/agenda_view.gd")', 'const AGENDA_VIEW := preload("res://game/ui/agenda_view.gd")\nconst PERSON_PANEL := preload("res://game/ui/person_panel.gd")')
    source = source.replace('var _agenda_view: RefCounted', 'var _agenda_view: RefCounted\nvar _person_panel: RefCounted')
    source = source.replace('\t_agenda_view = AGENDA_VIEW.new(self)\n', '\t_agenda_view = AGENDA_VIEW.new(self)\n\t_person_panel = PERSON_PANEL.new(self)\n', 1)
    source = source.replace('return TIPS[key]', 'return _person_panel._action_tip(key)')
else:
    raise SystemExit('usage: split_ui.py agenda|person')

path.write_text(source, encoding='utf-8')
