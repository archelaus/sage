#!/usr/bin/env bash

set -e

MAX_TOKENS=${MAX_TOKENS:-1024}
MODEL=${MODEL:-text-davinci-003}
TEMPERATURE=${TEMPERATURE:-0.7}

response=/tmp/openai_response
shell=false

# Color codes
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
bold=$(tput bold)
reset=$(tput sgr0)

if [[ $# -lt 1 ]]; then
  printf "Hi, I'm Sage. Ask me anything!\n"
  printf '%sUsage:%s sage %s[options]%s %squery%s\n' \
    "$green" "$reset" "$yellow" "$reset" "$magenta" "$reset"
  exit 0
fi

if ! [[ $OPENAI_KEY ]]; then
  printf "ERROR: '$OPENAI_KEY' is not set"
fi

show_help(){
  printf '%sUsage:%s sage %s[options]%s %squery%s\n' \
    "$green" "$reset" "$yellow" "$reset" "$magenta" "$reset"
}

shutdown() {
  tput cnorm # reset cursor
}
trap shutdown EXIT

cursorBack() {
  echo -en "\033[$1D"
}

spinner() {
  # make sure we use non-unicode character type locale
  # (that way it works for any locale as long as the font supports the characters)
  local LC_CTYPE=C

  local pid=$1 # Process Id of the previous running command

  local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
  local charwidth=3

  local i=0
  tput civis # cursor invisible
  while kill -0 $pid 2>/dev/null; do
    local i=$(((i + $charwidth) % ${#spin}))
    printf '%s' "${spin:$i:$charwidth}"

    cursorBack 1
    sleep .1
  done
  tput cnorm
  wait $pid # capture exit code
  return $?
}

handleError() {
  if jq -e '.error' "$1" > /dev/null; then
    printf '%sSage:%s %s\n' "$red" "$reset" "$(jq -r '.error.message' "$1")"
    exit 1
  fi
}

openai_request() {
  escaped_prompt=$(echo "$1" | sed 's/"/\\"/g')
  escaped_prompt=${escaped_prompt//$'\n'/' '}
  curl https://api.openai.com/v1/completions \
    -sS \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $OPENAI_KEY" \
    -d '{
      "model": "'"$MODEL"'",
      "prompt": "'"${escaped_prompt}"'",
      "max_tokens": '$MAX_TOKENS',
      "temperature": '$TEMPERATURE'
    }' > $response
}

while getopts :hs opt; do
  case $opt in
    h)
      show_help
      exit 0
      ;;
    s)
      shell=true
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done
shift "$((OPTIND-1))"

openai_request "$@" & spinner $!

handleError $response
response_data=$(jq -r '.choices[].text' "$response" | sed '1,2d')

printf '%sSage:%s %s\n' "$green" "$reset" "$response_data"
if [[ $shell = "true" ]]; then
  read -rp "${green}Sage:${reset} Execute the shell command? [yN] " confirm
  if [[ $confirm =~ ^[yY]$ ]]; then
    eval "$response_data"
  fi
fi
