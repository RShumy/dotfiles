#!bin/bash

echo "#[fg=$(tmux show -gqv @WIN_ACT_BG)]#[bg=$(tmux show -gqv @WIN_ACT_BG)]#[fg=$(tmux show -gqv @WIN_INA_FG)]$1>#[fg=$(tmux show -gqv @WIN_ACT_FG),bold]$2#[fg=$(tmux show -gqv @WIN_ACT_BG),bg=$(tmux show -gqv @STATUS_BG)]" 
#[fg=$(tmux show -gqv @WIN_ACT_FG),bold]$2#[bg=$(tmux show -gqv @STATUS_BG),fg=$(tmux show -gqv @WIN_ACT_BG)]"
