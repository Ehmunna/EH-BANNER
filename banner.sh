#!/data/data/com.termux/files/usr/bin/bash
# ================================================================
#  TERMUX ANIMATED BANNER  v2
#  ব্যবহার:
#     bash banner.sh              -> একবার চালিয়ে দেখুন
#     bash banner.sh --install    -> প্রতিবার Termux খুললে অটো চলবে + root prompt
#     bash banner.sh --uninstall  -> সব আগের মতো করে দেবে
# ================================================================

# ------------------------- CONFIG -------------------------------
NAME="MUNNA"           # বড় লোগোর নাম
OPERATOR="EH MUNNA"    # Operator ফিল্ড
THEME="red"            # red | green | cyan | purple
SPEED=0.008            # টাইপিং স্পিড (কম = দ্রুত, ০ = তাৎক্ষণিক)
RAIN_SECONDS=2         # rain মোট কতক্ষণ চলবে (সেকেন্ড, ১-৩ ভালো)
FIGFONT="standard"     # figlet ফন্ট: standard, slant, big, small, banner3 ...
# ----------------------------------------------------------------

ESC=$'\033'
case "$THEME" in
  green)  C=32 ;; cyan) C=36 ;; purple) C=35 ;; *) C=31 ;;
esac
R="${ESC}[1;${C}m"   # উজ্জ্বল মূল রঙ
D="${ESC}[0;${C}m"   # গাঢ় রঙ (লেজ/ফেড)
W="${ESC}[1;37m"     # সাদা
G="${ESC}[1;32m"     # সবুজ (OK / ACCESS / ONLINE ইত্যাদির জন্য)
N="${ESC}[0m"

COLS=${BANNER_COLS:-$(tput cols 2>/dev/null || echo 45)}
LINES_N=${BANNER_LINES:-$(tput lines 2>/dev/null || echo 24)}
HOST=$(echo "$NAME" | tr 'A-Z ' 'a-z-')

hide_cursor() { printf '%s' "${ESC}[?25l"; }
show_cursor() { printf '%s' "${ESC}[?25h"; }
cleanup() { show_cursor; printf '%s' "$N"; }

# ---------- টাইপরাইটার ----------
# রঙ দিয়ে লেখা এক এক অক্ষর করে টাইপ করে (লাইন শেষ করে না)
type_seg() {
  local color="$1" text="$2" i
  printf '%s' "$color"
  if [[ "$SPEED" == "0" ]]; then printf '%s' "$text"; return; fi
  for ((i=0; i<${#text}; i++)); do
    printf '%s' "${text:$i:1}"
    sleep "$SPEED"
  done
}

# পুরো লাইন টাইপ করে নতুন লাইনে যায়
type_text() {
  type_seg "${2:-$R}" "$1"
  printf '%s\n' "$N"
}

# ---------- 1) Matrix rain (সোজা নিচে পড়ে, লেজ মুছে যায়) ----------
matrix_rain() {
  local chars='01ABCDEFGHIJKLMNOPQRSTUVWXYZ$#%&@*<>/|=+'
  local nch=${#chars}
  local ncols=$(( (COLS + 1) / 2 ))
  local -a head len spd wh active
  local c x h p m t ch ch2 buf alive frame=0 spawning spawn_frames max_frames

  for ((c=0; c<ncols; c++)); do
    head[c]=$(( -(RANDOM % LINES_N) ))   # স্ক্রিনের উপরে আলাদা আলাদা সময়ে শুরু
    len[c]=$(( 5 + RANDOM % 10 ))
    spd[c]=$(( 1 + RANDOM % 2 ))
    (( RANDOM % 5 == 0 )) && wh[c]=1 || wh[c]=0   # প্রায় ৫টার ১টা কলামের মাথা সাদা
    active[c]=1
  done

  spawn_frames=$(( RAIN_SECONDS * 20 ))        # নতুন কলাম এই সময় পর্যন্ত পড়বে
  max_frames=$(( spawn_frames + 14 ))          # এরপর বড়জোর এতটুকু সময়েই শেষ
  clear
  while :; do
    buf=""; alive=0
    (( frame < spawn_frames )) && spawning=1 || spawning=0

    for ((c=0; c<ncols; c++)); do
      (( active[c] )) || continue
      alive=1
      (( frame % spd[c] )) && continue

      head[c]=$(( head[c] + 1 ))
      h=${head[c]}
      x=$(( c * 2 + 1 ))

      # মাথা
      if (( h >= 1 && h <= LINES_N )); then
        ch=${chars:RANDOM%nch:1}
        if (( wh[c] )); then buf+="${ESC}[${h};${x}H${W}${ch}"
        else                 buf+="${ESC}[${h};${x}H${R}${ch}"; fi
      fi
      # আগের মাথা -> উজ্জ্বল রঙ
      p=$(( h - 1 ))
      if (( p >= 1 && p <= LINES_N )); then
        ch=${chars:RANDOM%nch:1}
        buf+="${ESC}[${p};${x}H${R}${ch}"
      fi
      # মাঝখান -> গাঢ় (ফেড)
      m=$(( h - len[c] / 2 ))
      if (( m >= 1 && m <= LINES_N )); then
        ch2=${chars:RANDOM%nch:1}
        buf+="${ESC}[${m};${x}H${D}${ch2}"
      fi
      # লেজের শেষ -> মুছে ফেলো (এটাই আগের বাগ ঠিক করে)
      t=$(( h - len[c] ))
      if (( t >= 1 && t <= LINES_N )); then
        buf+="${ESC}[${t};${x}H "
      fi
      # পুরো কলাম নিচে চলে গেলে: নতুন করে শুরু বা বন্ধ
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
    frame=$((frame + 1))
    (( frame >= max_frames )) && break
    sleep 0.04
  done
  printf '%s' "$N"
  clear
}

# ---------- 2) বুট টাস্ক (টাইপিং ইফেক্টে) ----------
task() { type_text "[ OK ] $1" "$R"; }

boot_messages() {
  type_text "[!] RESTRICTED ACCESS >> ${NAME} TERMINAL" "$R"
  task "Initializing ${NAME} core" 10
  task "Establishing encrypted tunnel" 12
  task "Bypassing security layers" 14
  task "Loading kernel modules" 9
  type_text "[#] ROOT ACCESS : GRANTED" "$G"
  echo
}

# ---------- 3) বড় লোগো + গ্লিচ ----------
logo() {
  local txt n k col off l
  if command -v figlet >/dev/null 2>&1; then
    txt=$(figlet -f "$FIGFONT" -w $((COLS - 3)) "$NAME" 2>/dev/null || figlet "$NAME")
  else
    local line; line=$(printf '═%.0s' $(seq 1 $((${#NAME} + 4))))
    txt=$(printf '╔%s╗\n║  %s  ║\n╚%s╝' "$line" "$NAME" "$line")
  fi
  n=$(printf '%s\n' "$txt" | wc -l)

  # প্রথমবার আঁকা
  while IFS= read -r l; do printf '%s%s%s\n' "$R" "$l" "$N"; done <<<"$txt"

  # গ্লিচ: রঙ বদলায় ও একটু ডানে-বামে কাঁপে
  for k in 1 2 3 4 5 6; do
    printf '%s[%dA' "$ESC" "$n"
    case $((k % 3)) in 0) col=$W ;; 1) col=$D ;; *) col=$R ;; esac
    off=$(printf '%*s' $((RANDOM % 3)) '')
    while IFS= read -r l; do printf '%s%s%s%s[K\n' "$col" "$off" "$l" "$ESC"; done <<<"$txt"
    sleep 0.07
  done
  # শেষে স্থির
  printf '%s[%dA' "$ESC" "$n"
  while IFS= read -r l; do printf '%s%s%s%s[K\n' "$R" "$l" "$N" "$ESC"; done <<<"$txt"

  printf '%s   [ SYSTEM SECURED BY %s ]%s\n\n' "$R" "$NAME" "$N"
}

# ---------- 4) Progress bar ----------
progress() {
  local width=$((COLS - 22)); (( width > 30 )) && width=30; (( width < 10 )) && width=10
  local i j f e
  for ((i=0; i<=width; i++)); do
    f=""; e=""
    for ((j=0; j<i; j++)); do f+="▰"; done
    for ((j=i; j<width; j++)); do e+="▱"; done
    printf '\r%s> Decrypting: [%s%s%s%s%s] %3d%%%s' \
      "$G" "$G" "$f" "${ESC}[0;32m" "$e" "$G" "$((i * 100 / width))" "$N"
    sleep 0.0$((2 + RANDOM % 6))
  done
  printf '\n\n'
}

# ---------- 5) Info box ----------
collect_info() {
  I_MODEL=$(getprop ro.product.model 2>/dev/null); I_MODEL=${I_MODEL:-$(uname -m)}
  I_KERNEL=$(uname -r | cut -d- -f1)
  I_NETC="$G"
  if ping -c1 -W1 8.8.8.8 >/dev/null 2>&1; then I_NET="ONLINE"; else I_NET="OFFLINE"; I_NETC="$R"; fi
}

info_row() {
  type_seg "$R" "│ $(printf '%-9s' "$1"): "
  type_seg "${3:-$W}" "$2"
  printf '%s\n' "$N"
}

# বক্স + শেষ লাইন আঁকে (SPEED=0 হলে এক ঝটকায়)
draw_box() {
  type_text "┌──────────────────────────────" "$R"
  info_row "STATUS"   "COMPROMISED"
  info_row "OPERATOR" "$OPERATOR"
  info_row "ACCESS"   "ROOT / ADMIN" "$G"
  info_row "DEVICE"   "$I_MODEL"
  info_row "KERNEL"   "kernel-$I_KERNEL"
  info_row "NETWORK"  "$I_NET" "$I_NETC"
  info_row "TIME"     "$(date +%H:%M:%S)"
  info_row "DATE"     "$(date +%d-%m-%Y)"
  type_text "└──────────────────────────────" "$R"
  echo
  type_text "Hack the system rule the game" "$G"
  echo
}

# ---------- 6) অ্যানিমেশন শেষে: স্ক্রিন মুছে শুধু বক্স + লাইন রাখে ----------
final_screen() {
  sleep 0.8
  clear
  local SPEED=0
  draw_box
}

# ---------- Install / Uninstall ----------
install_hook() {
  local rc="$HOME/.bashrc" me
  me=$(readlink -f "$0")
  if grep -q '# >>> termux-banner >>>' "$rc" 2>/dev/null; then
    echo "আগেই ইনস্টল করা আছে।"; exit 0
  fi
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

main() {
  trap cleanup EXIT INT TERM
  hide_cursor
  matrix_rain
  boot_messages
  logo
  progress
  collect_info
  draw_box
  final_screen
  show_cursor
}

# স্ক্রিপ্ট সরাসরি চালালেই শুধু main চলবে (source করলে নয়)
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  case "$1" in
    --install)   install_hook ;;
    --uninstall) uninstall_hook ;;
    *)           main ;;
  esac
fi
