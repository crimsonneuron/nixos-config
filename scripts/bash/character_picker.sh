#!/usr/bin/env bash
declare -A characters
characters[shrug]="¯\_(ツ)_/¯"
characters[tm]="™"
characters[alpha]="α"
characters[beta]="β"
characters[gamma]="γ"
characters[delta]="δ"
characters[epsilon]="ε"
characters[zeta]="ζ"
characters[eta]="η"
characters[theta]="θ"
characters[iota]="ι"
characters[kappa]="κ"
characters[lambda]="λ"
characters[mu]="μ"
characters[nu]="ν"
characters[xi]="ξ"
characters[omicron]="ο"
characters[pi]="π"
characters[rho]="ρ"
characters[sigma]="σ"
characters[tau]="τ"
characters[upsilon]="υ"
characters[phi]="φ"
characters[chi]="χ"
characters[psi]="ψ"
characters[omega]="ω"

input_string=""
for name in "${!characters[@]}"
do
    input_string+="$name\n"
done
env > /tmp/tofi-env.txt
pwd >>/tmp/tofi-env.txt
chosen=$(printf "$input_string" | tofi --prompt-text="Char: " --require-match=false --font="/home/crimson/.nix-profile/share/fonts/truetype/NerdFonts/FantasqueSansM/FantasqueSansMNerdFont-Regular.ttf" -c "/home/crimson/nixos/dotfiles/tofi/dmenu")
printf "${characters[$chosen]}" | wl-copy
