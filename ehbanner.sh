#!/data/data/com.termux/files/usr/bin/bash
# ================================================================
#  TERMUX ANIMATED BANNER  v4  — MUNNA EDITION
#  bash ban.sh              -> একবার চালান
#  bash ban.sh --install    -> অটো চলবে Termux খুললে
#  bash ban.sh --uninstall  -> সরিয়ে ফেলবে
# ================================================================

# ───────────────────── CONFIG ─────────────────────
NAME="MUNNA"
OPERATOR="EH MUNNA"
THEME="red"            # red | green | cyan | purple
SPEED=0.007
RAIN_SECONDS=2
# ──────────────────────────────────────────────────

ESC=$'\033'
case "$THEME" in
  green)  C=32; GRAD=(46 46 40 34 28 22)      ;;
  cyan)   C=36; GRAD=(51 45 39 33 27 21)      ;;
  purple) C=35; GRAD=(213 177 141 105 99 93)  ;;
  *)      C=31; GRAD=(203 196 196 160 124 88) ;;
esac

R="${ESC}[1;${C}m"
D="${ESC}[0;${C}m"
W="${ESC}[1;37m"
G="${ESC}[1;32m"
Y="${ESC}[1;33m"
N="${ESC}[0m"

COLS=${BANNER_COLS:-$(tput cols 2>/dev/null || echo 50)}
LINES_N=${BANNER_LINES:-$(tput lines 2>/dev/null || echo 24)}

hide_cursor() { printf '%s' "${ESC}[?25l"; }
show_cursor() { printf '%s' "${ESC}[?25h"; }
cleanup()     { show_cursor; printf '%s' "$N"; }

# ───── টাইপরাইটার ─────
type_seg() {
  local color="$1" text="$2" i
  printf '%s' "$color"
  [[ "$SPEED" == "0" ]] && { printf '%s' "$text"; return; }
  for ((i=0; i<${#text}; i++)); do
    printf '%s' "${text:$i:1}"
    sleep "$SPEED"
  done
}
type_text() { type_seg "${2:-$R}" "$1"; printf '%s\n' "$N"; }

# ───── 1) Matrix Rain ─────
matrix_rain() {
  local chars='01ABCDEFGHIJKLMNOPQRSTUVWXYZ$#%&@*<>/|=+'
  local nch=${#chars}
  local ncols=$(( (COLS + 1) / 2 ))
  local -a head len spd wh active
  local c x h p m t ch buf alive frame=0 spawning spawn_frames max_frames

  for ((c=0; c<ncols; c++)); do
    head[c]=$(( -(RANDOM % LINES_N) ))
    len[c]=$(( 5 + RANDOM % 10 ))
    spd[c]=$(( 1 + RANDOM % 2 ))
    (( RANDOM % 5 == 0 )) && wh[c]=1 || wh[c]=0
    active[c]=1
  done

  spawn_frames=$(( RAIN_SECONDS * 20 ))
  max_frames=$(( spawn_frames + 14 ))
  clear

  while :; do
    buf=""; alive=0
    (( frame < spawn_frames )) && spawning=1 || spawning=0
    for ((c=0; c<ncols; c++)); do
      (( active[c] )) || continue
      alive=1
      (( frame % spd[c] )) && continue
      head[c]=$(( head[c] + 1 ))
      h=${head[c]}; x=$(( c * 2 + 1 ))
      if (( h >= 1 && h <= LINES_N )); then
        ch=${chars:RANDOM%nch:1}
        (( wh[c] )) \
          && buf+="${ESC}[${h};${x}H${W}${ch}" \
          || buf+="${ESC}[${h};${x}H${R}${ch}"
      fi
      p=$(( h-1 ))
      (( p>=1 && p<=LINES_N )) \
        && buf+="${ESC}[${p};${x}H${R}${chars:RANDOM%nch:1}"
      m=$(( h - len[c]/2 ))
      (( m>=1 && m<=LINES_N )) \
        && buf+="${ESC}[${m};${x}H${D}${chars:RANDOM%nch:1}"
      t=$(( h - len[c] ))
      (( t>=1 && t<=LINES_N )) && buf+="${ESC}[${t};${x}H "
      if (( t > LINES_N )); then
        if (( spawning )); then
          head[c]=$(( -(RANDOM % LINES_N) ))
          len[c]=$(( 5 + RANDOM % 10 ))
          spd[c]=$(( 1 + RANDOM % 2 ))
          (( RANDOM % 5 == 0 )) && wh[c]=1 || wh[c]=0
        else
          active[c]=0
        fi
      fi
    done
    printf '%s' "$buf"
    (( alive )) || break
    frame=$(( frame+1 ))
    (( frame >= max_frames )) && break
    sleep 0.04
  done
  printf '%s' "$N"; clear
}

# ───── 2) Glitch flash ─────
glitch_flash() {
  local glyphs=('▓▒░█▀▄■□▪▫◘◙' '▐▌╬╫╪╩╦╠╝╚╔╗' '▰▱▲▼◆◇○●◉◎')
  local i row pad sp maxlen=28
  pad=$(( (COLS - maxlen) / 2 ))
  (( pad < 0 )) && pad=0
  printf -v sp '%*s' "$pad" ''
  for ((i=0; i<5; i++)); do
    row="${glyphs[RANDOM%3]}"
    printf '%s%s%s%s\n' "$sp" "$R" "${row:0:$((maxlen/2+RANDOM%6))}" "$N"
    sleep 0.04
    printf '%s' "${ESC}[1A${ESC}[2K"
  done
}

# ───── 3) MUNNA Logo — centered ─────
ART_BIG=$(cat <<'ART'
███╗   ███╗██╗   ██╗███╗   ██╗███╗   ██╗ █████╗ 
████╗ ████║██║   ██║████╗  ██║████╗  ██║██╔══██╗
██╔████╔██║██║   ██║██╔██╗ ██║██╔██╗ ██║███████║
██║╚██╔╝██║██║   ██║██║╚██╗██║██║╚██╗██║██╔══██║
██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██║ ╚████║██║  ██║
╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚═╝  ╚═╝
ART
)

ART_SMALL=$(cat <<'ART'
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
█▄ ▄█ █ █ █▄  █ █▄  █ ▄▀▀▀▄ █
█ █ █ █ █ █▀▄ █ █▀▄ █ █▄▄▄█ █
█   █ █ █ █  ██ █  ██ █   █ █
▀   ▀  ▀▀  ▀   ▀ ▀   ▀ ▀   ▀ ▀
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
ART
)

logo() {
  local -a rows
  local n i idx maxlen rowlen pad sp

  if (( COLS >= 56 )); then
    mapfile -t rows <<<"$ART_BIG"
  elif command -v figlet >/dev/null 2>&1; then
    mapfile -t rows < <(figlet -f standard -w $((COLS-2)) "$NAME")
  else
    mapfile -t rows <<<"$ART_SMALL"
  fi

  # সবচেয়ে লম্বা লাইনের দৈর্ঘ্য বের করো
  maxlen=0
  for i in "${rows[@]}"; do
    rowlen=${#i}
    (( rowlen > maxlen )) && maxlen=$rowlen
  done

  # center padding
  pad=$(( (COLS - maxlen) / 2 ))
  (( pad < 0 )) && pad=0
  printf -v sp '%*s' "$pad" ''

  glitch_flash

  n=${#rows[@]}
  for ((i=0; i<n; i++)); do
    idx=$(( i * ${#GRAD[@]} / n ))
    printf '%s%s%s%s\n' "$sp" "${ESC}[38;5;${GRAD[idx]}m" "${rows[i]}" "$N"
    sleep 0.09
  done
  echo
}

# ───── 4) Subtitle bar — centered ─────
subtitle_bar() {
  local line="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  local text="  ◈  MUNNA — SECURE TERMINAL  ◈  "
  local ll=${#line}
  local pad=$(( (COLS - ll) / 2 ))
  (( pad < 0 )) && pad=0
  local sp; printf -v sp '%*s' "$pad" ''

  printf '%s%s%s%s\n' "$sp" "$R" "$line" "$N"
  printf '%s%s%s%s\n' "$sp" "$W" "$text" "$N"
  printf '%s%s%s%s\n' "$sp" "$R" "$line" "$N"
  echo
}

# ───── 5) Boot Messages ─────
task_ok()   { type_text "  ${G}[  OK  ]${N}  ${R}$1${N}"; sleep 0.04; }
task_warn() { type_text "  ${Y}[ WARN ]${N}  ${Y}$1${N}"; sleep 0.04; }
task_root() { type_text "  ${G}[ ROOT ]${N}  ${G}$1${N}"; sleep 0.04; }

boot_messages() {
  echo
  type_text "  ${R}[!] INITIATING ${NAME} SECURE TERMINAL ...${N}"
  echo
  sleep 0.1
  task_ok   "Loading encrypted kernel modules"
  task_ok   "Establishing secure tunnel [AES-256]"
  task_ok   "Bypassing perimeter firewall"
  task_warn "Intrusion detection   :  DISABLED"
  task_ok   "Injecting payload handler"
  task_ok   "Memory protection     :  ACTIVE"
  task_root "PRIVILEGE ESCALATION COMPLETE"
  echo
  type_text "  ${G}[#] ROOT ACCESS : GRANTED — WELCOME, ${OPERATOR}${N}"
  echo
}

# ───── 6) Progress bar ─────
progress() {
  local width=$(( COLS - 24 ))
  (( width > 34 )) && width=34
  (( width < 10 )) && width=10
  local i j f e
  for ((i=0; i<=width; i++)); do
    f=""; e=""
    for ((j=0; j<i; j++));     do f+="▰"; done
    for ((j=i; j<width; j++)); do e+="▱"; done
    printf '\r  %s◈ Decrypting : [%s%s%s%s%s] %3d%%%s' \
      "$G" "$G" "$f" "${ESC}[0;32m" "$e" "$G" "$(( i*100/width ))" "$N"
    sleep 0.0$(( 2 + RANDOM % 5 ))
  done
  printf '\n\n'
}

# ───── 7) Info Box — centered, no uptime ─────
collect_info() {
  I_MODEL=$(getprop ro.product.model 2>/dev/null)
  I_MODEL=${I_MODEL:-$(uname -m)}
  I_KERNEL=$(uname -r | cut -d- -f1)
  I_USER=$(whoami 2>/dev/null || echo "root")
  I_SHELL=$(basename "$SHELL")
  I_NETC="$G"; I_NET="ONLINE"
  ping -c1 -W1 8.8.8.8 >/dev/null 2>&1 || { I_NET="OFFLINE"; I_NETC="$R"; }
}

draw_box() {
  local BW=38
  local pad=$(( (COLS - BW) / 2 ))
  (( pad < 0 )) && pad=0
  local sp; printf -v sp '%*s' "$pad" ''

  _row() {
    printf '%s' "$sp"
    type_seg "$R"       "║  "
    type_seg "$R"       "$(printf '%-10s' "$1")"
    type_seg "$D"       " ◈  "
    type_seg "${3:-$W}" "$2"
    printf '%s\n' "$N"
  }
  _sep() {
    printf '%s' "$sp"
    type_text "╠══════════════════════════════════════╣" "$D"
  }

  printf '%s'; type_text "${sp}╔══════════════════════════════════════╗" "$R"
  printf '%s%s%s%s\n' \
    "$sp" "${R}║" \
    "${W}$(printf '%*s%-*s' 13 '' 25 '    ◈  MUNNA  v4  ◈')" \
    "${R}║${N}"
  _sep
  _row  "STATUS"   "COMPROMISED"       "$R"
  _row  "OPERATOR" "$OPERATOR"         "$W"
  _sep
  _row  "ACCESS"   "ROOT / ADMIN"      "$G"
  _row  "USER"     "$I_USER"           "$W"
  _row  "SHELL"    "$I_SHELL"          "$W"
  _sep
  _row  "DEVICE"   "$I_MODEL"          "$W"
  _row  "KERNEL"   "Linux $I_KERNEL"   "$W"
  _sep
  _row  "NETWORK"  "$I_NET"            "$I_NETC"
  _row  "TIME"     "$(date +%H:%M:%S)" "$W"
  _row  "DATE"     "$(date +%d-%m-%Y)" "$W"
  printf '%s'; type_text "${sp}╚══════════════════════════════════════╝" "$R"
  echo
}

# ───── 8) Tagline ─────
tagline() {
  type_text "  ⚡  HACK THE SYSTEM. RULE THE GAME.  ⚡" "$G"
  type_text "  ◈  t.me/EHMunna  |  YT: @EHMunna-1   " "$D"
  echo
}

# ───── 9) Final screen ─────
final_screen() {
  sleep 0.6
  clear
  local SPEED=0
  logo
  subtitle_bar
  draw_box
  tagline
}

# ───── Install / Uninstall ─────
install_hook() {
  local rc="$HOME/.bashrc" me
  me=$(readlink -f "$0")
  grep -q '# >>> termux-banner >>>' "$rc" 2>/dev/null && {
    echo "আগেই ইনস্টল করা আছে।"; exit 0
  }
  cat >> "$rc" <<EOF
# >>> termux-banner >>>
[ -z "\$BANNER_SHOWN" ] && export BANNER_SHOWN=1 && bash "$me"
# <<< termux-banner <<<
EOF
  echo "ইনস্টল হয়েছে। Termux বন্ধ করে আবার খুলুন।"
}

uninstall_hook() {
  sed -i '/# >>> termux-banner >>>/,/# <<< termux-banner <<</d' "$HOME/.bashrc"
  echo "সরিয়ে ফেলা হয়েছে।"
}

# ───── Main ─────
main() {
  trap cleanup EXIT INT TERM
  hide_cursor
  matrix_rain
  boot_messages
  logo
  subtitle_bar
  progress
  collect_info
  draw_box
  tagline
  final_screen
  show_cursor
}

[[ "${BASH_SOURCE[0]}" == "$0" ]] && case "$1" in
  --install)   install_hook ;;
  --uninstall) uninstall_hook ;;
  *)           main ;;
esac
