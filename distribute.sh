#!/usr/bin/env bash
set -euo pipefail

# ================================================================
#  WayMark — Interactive Distribution Script
#  Builds & distributes the app for a chosen environment via Fastlane
#  Usage: chmod +x distribute.sh && ./distribute.sh
# ================================================================

BOLD="\033[1m"
GREEN="\033[32m"
TEAL="\033[36m"
RESET="\033[0m"

echo ""
echo -e "${TEAL}${BOLD}"
echo "  ██╗    ██╗ █████╗ ██╗   ██╗███╗   ███╗ █████╗ ██████╗ ██╗  ██╗"
echo "  ██║    ██║██╔══██╗╚██╗ ██╔╝████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝"
echo "  ██║ █╗ ██║███████║ ╚████╔╝ ██╔████╔██║███████║██████╔╝█████╔╝ "
echo "  ██║███╗██║██╔══██║  ╚██╔╝  ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ "
echo "  ╚███╔███╔╝██║  ██║   ██║   ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗"
echo "   ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝"
echo -e "${RESET}"
echo -e "  ${BOLD}Offline-First Travel Field Journal — Distribution Pipeline${RESET}"
echo ""
echo "================================================================"
echo ""

# ── Environment Selection ──────────────────────────────────────────
echo -e "${BOLD}Select environment to build and distribute:${RESET}"
echo "  1) Dev"
echo "  2) QA"
echo "  3) UAT"
echo "  4) Production"
echo ""
read -rp "Enter selection [1-4]: " env_choice

case "$env_choice" in
  1) ENV="dev"   ; ENV_LABEL="Dev"        ;;
  2) ENV="qa"    ; ENV_LABEL="QA"         ;;
  3) ENV="uat"   ; ENV_LABEL="UAT"        ;;
  4) ENV="prod"  ; ENV_LABEL="Production" ;;
  *)
    echo -e "\n❌  Invalid selection. Exiting."
    exit 1
    ;;
esac

# ── Platform Selection ─────────────────────────────────────────────
echo ""
echo -e "${BOLD}Select platform:${RESET}"
echo "  1) iOS"
echo "  2) Android"
echo "  3) Both"
echo ""
read -rp "Enter selection [1-3]: " platform_choice

case "$platform_choice" in
  1) PLATFORM="ios"     ;;
  2) PLATFORM="android" ;;
  3) PLATFORM="both"    ;;
  *)
    echo -e "\n❌  Invalid platform selection. Exiting."
    exit 1
    ;;
esac

# ── Release Notes ──────────────────────────────────────────────────
echo ""
read -rp "Release notes (press Enter to skip): " NOTES
if [ -z "$NOTES" ]; then
  NOTES="$(date '+%Y-%m-%d') — ${ENV_LABEL} build"
fi

# ── Summary ────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}▶  Building and distributing:${RESET}"
echo "   Environment : $ENV_LABEL"
echo "   Platform    : $PLATFORM"
echo "   Notes       : $NOTES"
echo ""
read -rp "Proceed? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# ── Execute Fastlane ───────────────────────────────────────────────
run_ios() {
  echo -e "\n${TEAL}▶  Running iOS Fastlane lane: distribute_${ENV}${RESET}"
  (cd ios && bundle exec fastlane "distribute_${ENV}" notes:"$NOTES")
}

run_android() {
  echo -e "\n${TEAL}▶  Running Android Fastlane lane: distribute_${ENV}${RESET}"
  (cd android && bundle exec fastlane "distribute_${ENV}" notes:"$NOTES")
}

case "$PLATFORM" in
  ios)     run_ios ;;
  android) run_android ;;
  both)    run_ios && run_android ;;
esac

echo ""
echo -e "${GREEN}${BOLD}✓  Distribution complete!${RESET}"
echo ""
