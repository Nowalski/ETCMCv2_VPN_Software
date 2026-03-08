#!/usr/bin/env bash
# =============================================================================
#  ETCMCv2 VPN Server Manager
#  Usage: bash manage.sh
# =============================================================================

set -euo pipefail

R='\033[0;31m'; G='\033[0;32m'; Y='\033[0;33m'; B='\033[0;34m'
C='\033[0;36m'; W='\033[1;37m'; D='\033[0;90m'; NC='\033[0m'
BOLD='\033[1m'; DIM='\033[2m'

CONTAINER="shadowbox"
SB_DIR="${SHADOWBOX_DIR:-/opt/etcmc}"

# ── Header ────────────────────────────────────────────────────────────────────
header() {
  clear
  echo -e "${B}${BOLD}"
  echo "  ███████╗████████╗ ██████╗███╗   ███╗ ██████╗ ██╗   ██╗██████╗ "
  echo "  ██╔════╝╚══██╔══╝██╔════╝████╗ ████║██╔════╝ ██║   ██║╚════██╗"
  echo "  █████╗     ██║   ██║     ██╔████╔██║██║      ██║   ██║ █████╔╝"
  echo "  ██╔══╝     ██║   ██║     ██║╚██╔╝██║██║      ╚██╗ ██╔╝██╔═══╝ "
  echo "  ███████╗   ██║   ╚██████╗██║ ╚═╝ ██║╚██████╗  ╚████╔╝ ███████╗"
  echo "  ╚══════╝   ╚═╝    ╚═════╝╚═╝     ╚═╝ ╚═════╝   ╚═══╝  ╚══════╝"
  echo -e "${NC}${D}  ETCMCv2 VPN Server Manager — Shadowbox Edition${NC}"
  echo ""
  echo -e "  ${DIM}$(hostname)  |  $(date '+%Y-%m-%d %H:%M:%S')${NC}"
  echo -e "  ${D}──────────────────────────────────────────────────────────${NC}"
  echo ""
}

pause() {
  echo ""; echo -e "  ${DIM}Press Enter to go back...${NC}"; read -r
}

running()  { docker ps    --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER}$"; }
exists()   { docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER}$"; }

# ── 1. Status ─────────────────────────────────────────────────────────────────
status() {
  header
  echo -e "  ${W}${BOLD}SERVER STATUS${NC}\n"

  if ! docker info &>/dev/null; then
    echo -e "  ${R}✗  Docker is not running${NC}"
    echo -e "     ${DIM}Fix: sudo systemctl start docker${NC}"
    pause; return
  fi
  echo -e "  ${G}✔  Docker daemon        — running${NC}"

  if running; then
    echo -e "  ${G}✔  Shadowbox container  — ${BOLD}ONLINE${NC}"
    echo ""
    echo -e "  ${W}Details:${NC}"
    docker inspect --format \
      "     Image  : {{.Config.Image}}
     Started: {{.State.StartedAt}}" \
      "$CONTAINER" 2>/dev/null || true
    echo ""
    echo -e "  ${W}Resources:${NC}"
    docker stats --no-stream --format \
      "     CPU    : {{.CPUPerc}}
     Memory : {{.MemUsage}}
     Net I/O: {{.NetIO}}" \
      "$CONTAINER" 2>/dev/null || true
  elif exists; then
    echo -e "  ${Y}!  Shadowbox container  — STOPPED${NC}"
    echo -e "     ${DIM}Fix: docker start ${CONTAINER}${NC}"
  else
    echo -e "  ${R}✗  Shadowbox container  — NOT FOUND${NC}"
    echo -e "     ${DIM}Run install_server.sh to set it up${NC}"
  fi

  echo ""
  if [ -d "$SB_DIR" ]; then
    SIZE=$(du -sh "$SB_DIR" 2>/dev/null | cut -f1 || echo "?")
    echo -e "  ${G}✔  Data folder: ${DIM}${SB_DIR}${NC}  (${SIZE})"
  else
    echo -e "  ${R}✗  Data folder not found: ${DIM}${SB_DIR}${NC}"
  fi

  if [ -f "${SB_DIR}/access.txt" ]; then
    echo ""
    echo -e "  ${W}Access Key:${NC}"
    echo -e "  ${C}$(cat "${SB_DIR}/access.txt")${NC}"
  fi

  pause
}

# ── 2. Live Logs ──────────────────────────────────────────────────────────────
logs() {
  header
  echo -e "  ${W}${BOLD}LIVE LOGS${NC}\n"

  if ! exists; then
    echo -e "  ${R}✗  Container not found.${NC}"
    pause; return
  fi

  echo -e "  ${DIM}Showing last 50 lines + live stream. Press Ctrl+C to stop.${NC}"
  echo -e "  ${D}──────────────────────────────────────────${NC}\n"
  docker logs -f --tail=50 "$CONTAINER" 2>&1 || true
  echo ""
  echo -e "  ${DIM}Stream ended.${NC}"
  pause
}

# ── 3. Restart ────────────────────────────────────────────────────────────────
restart() {
  header
  echo -e "  ${W}${BOLD}RESTART SERVER${NC}\n"

  if ! exists; then
    echo -e "  ${R}✗  Container not found.${NC}"
    pause; return
  fi

  echo -ne "  Restarting ${BOLD}${CONTAINER}${NC}... "
  if docker restart "$CONTAINER" &>/dev/null; then
    echo -e "${G}done${NC}"
  else
    echo -e "${R}failed — check logs for details${NC}"
  fi

  pause
}

# ── 4. Port Help ──────────────────────────────────────────────────────────────
ports() {
  header
  echo -e "  ${W}${BOLD}FIREWALL & PORT REQUIREMENTS${NC}\n"
  echo -e "  Open these ports so VPN clients can connect:\n"

  echo -e "  ${Y}┌───────────────┬──────────┬──────────────────────────────────┐${NC}"
  echo -e "  ${Y}│${NC}  ${W}Port${NC}          ${Y}│${NC}  ${W}Proto${NC}   ${Y}│${NC}  ${W}Purpose${NC}                         ${Y}│${NC}"
  echo -e "  ${Y}├───────────────┼──────────┼──────────────────────────────────┤${NC}"
  echo -e "  ${Y}│${NC}  ${G}443${NC}           ${Y}│${NC}  TCP     ${Y}│${NC}  VPN client connections           ${Y}│${NC}"
  echo -e "  ${Y}│${NC}  ${G}1024–65535${NC}    ${Y}│${NC}  UDP     ${Y}│${NC}  VPN data tunnel                  ${Y}│${NC}"
  echo -e "  ${Y}│${NC}  ${C}(random)${NC}      ${Y}│${NC}  TCP     ${Y}│${NC}  Shadowbox Management API         ${Y}│${NC}"
  echo -e "  ${Y}└───────────────┴──────────┴──────────────────────────────────┘${NC}\n"

  # Auto-detect API port
  API_PORT=""
  if running; then
    API_PORT=$(docker exec "$CONTAINER" sh -c 'echo $SB_API_PORT' 2>/dev/null || true)
  fi

  if [ -n "${API_PORT:-}" ]; then
    echo -e "  ${G}✔  Your Management API port: ${BOLD}${API_PORT}${NC}\n"
  else
    echo -e "  ${Y}  Management API port — run this to find it:${NC}"
    echo -e "    ${C}docker exec shadowbox sh -c 'echo \$SB_API_PORT'${NC}\n"
  fi

  echo -e "  ${W}UFW (Ubuntu/Debian):${NC}"
  echo -e "    ${G}sudo ufw allow 443/tcp${NC}"
  echo -e "    ${G}sudo ufw allow 1024:65535/udp${NC}"
  [ -n "${API_PORT:-}" ] \
    && echo -e "    ${G}sudo ufw allow ${API_PORT}/tcp${NC}" \
    || echo -e "    ${G}sudo ufw allow <API_PORT>/tcp${NC}"
  echo -e "    ${G}sudo ufw reload${NC}\n"

  echo -e "  ${W}firewalld (CentOS/Rocky):${NC}"
  echo -e "    ${G}sudo firewall-cmd --permanent --add-port=443/tcp${NC}"
  echo -e "    ${G}sudo firewall-cmd --permanent --add-port=1024-65535/udp${NC}"
  [ -n "${API_PORT:-}" ] \
    && echo -e "    ${G}sudo firewall-cmd --permanent --add-port=${API_PORT}/tcp${NC}" \
    || echo -e "    ${G}sudo firewall-cmd --permanent --add-port=<API_PORT>/tcp${NC}"
  echo -e "    ${G}sudo firewall-cmd --reload${NC}\n"

  echo -e "  ${Y}TIP:${NC} Cloud users (AWS, DigitalOcean, etc.) must also open"
  echo -e "  these ports in their provider's security group / firewall.\n"

  pause
}

# ── 5. Remove ─────────────────────────────────────────────────────────────────
remove() {
  header
  echo -e "  ${R}${BOLD}REMOVE EVERYTHING${NC}\n"
  echo -e "  ${Y}⚠  This will permanently delete:${NC}"
  echo -e "     • Shadowbox container & image"
  echo -e "     • All data in ${W}${SB_DIR}/${NC} (keys, certs, config)\n"
  echo -e "  ${R}${BOLD}Your VPN server will stop working immediately.${NC}\n"
  echo -ne "  Type ${W}DELETE${NC} to confirm, or Enter to cancel: "
  read -r confirm; echo ""

  if [ "$confirm" != "DELETE" ]; then
    echo -e "  ${G}Cancelled. Nothing changed.${NC}"
    pause; return
  fi

  ERRORS=0

  step() { echo -ne "  [$1] $2... "; }
  ok()   { echo -e "${G}done${NC}"; }
  skip() { echo -e "${DIM}$1${NC}"; }
  fail() { echo -e "${R}failed${NC}"; ERRORS=$((ERRORS+1)); }

  if exists; then
    step "1/4" "Stopping container"
    running && { docker stop "$CONTAINER" &>/dev/null && ok || fail; } || skip "already stopped"
    step "2/4" "Removing container"
    docker rm "$CONTAINER" &>/dev/null && ok || fail
  else
    skip "1/4 — container not found, skipping"
    skip "2/4 — container not found, skipping"
  fi

  step "3/4" "Removing Docker image"
  IMG=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -iE 'shadowbox|outline' | head -1 || true)
  if [ -n "${IMG:-}" ]; then
    docker rmi "$IMG" &>/dev/null && ok || skip "skipped (in use)"
  else
    skip "no image found"
  fi

  step "4/4" "Removing data folder"
  if [ -d "$SB_DIR" ]; then
    rm -rf "$SB_DIR" && ok || { echo -e "${R}failed — try: sudo rm -rf ${SB_DIR}${NC}"; ERRORS=$((ERRORS+1)); }
  else
    skip "not found"
  fi

  echo ""
  [ "$ERRORS" -eq 0 ] \
    && echo -e "  ${G}${BOLD}✔  Shadowbox completely removed.${NC}" \
    || echo -e "  ${Y}Done with ${ERRORS} error(s). See above.${NC}"

  pause
}

# ── Main ──────────────────────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  echo -e "${R}Docker is not installed. Install it first.${NC}"
  exit 1
fi

while true; do
  header
  echo -e "  ${W}What would you like to do?${NC}\n"
  echo -e "  ${G}[1]${NC}  Server Status       — check if everything is running"
  echo -e "  ${G}[2]${NC}  Live Logs           — watch real-time server output"
  echo -e "  ${G}[3]${NC}  Restart Server      — restart the VPN container"
  echo -e "  ${Y}[4]${NC}  Port Help           — which ports to open in your firewall"
  echo -e "  ${R}[5]${NC}  Remove Everything   — completely uninstall this server"
  echo -e "  ${D}[0]${NC}  Exit\n"
  echo -ne "  ${W}Choice:${NC} "
  read -r choice

  case "$choice" in
    1) status  ;;
    2) logs    ;;
    3) restart ;;
    4) ports   ;;
    5) remove  ;;
    0|q|Q) echo ""; echo -e "  ${DIM}Goodbye.${NC}"; echo ""; exit 0 ;;
    *) echo -e "  ${R}Invalid option.${NC}"; sleep 1 ;;
  esac
done
