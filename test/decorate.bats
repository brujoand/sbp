#!/usr/bin/env bats

load src_helper

@test "test that we get black when complementing a light color" {
  local dark='40;40;40'
  local light='249;248;245'
  local white='255;255;255'
  local black='0;0;0'

  local should_be_white
  decorate::calculate_complementing_color 'should_be_white' "$dark"
  assert_equal "$should_be_white" "$white"

  local should_be_black
  decorate::calculate_complementing_color 'should_be_black' "$light"
  assert_equal "$should_be_black" "$black"
}

@test "test that we can print valid 256 colors" {
  local fg_color=1
  local bg_color=2
  local expected_colors="\[\e[38;5;${fg_color}m\]\[\e[48;5;${bg_color}m\]"

  local printed_colors
  decorate::print_colors 'printed_colors' "$fg_color" "$bg_color"

  assert_equal "$printed_colors" "$expected_colors"
}

@test "test that we can print valid rgb colors" {
  local fg_color='255;255;255'
  local bg_color='0;0;1'
  local expected_colors="\[\e[38;2;${fg_color}m\]\[\e[48;2;${bg_color}m\]"

  local printed_colors
  decorate::print_colors 'printed_colors' "$fg_color" "$bg_color"

  assert_equal "$printed_colors" "$expected_colors"
}

@test "test that we can print valid reset colors" {
  local fg_color=''
  local bg_color=''
  local expected_colors="\[\e[39m\]\[\e[49m\]"

  local printed_colors
  decorate::print_colors 'printed_colors' "$fg_color" "$bg_color"

  assert_equal "$printed_colors" "$expected_colors"
}

