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

@test "test that we can print valid colors" {

}
