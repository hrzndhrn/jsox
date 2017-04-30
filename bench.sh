#!/bin/bash
MIX_ENV=bench mix compile
MIX_ENV=bench mix bench bench/parser_bench.exs
# MIX_ENV=bench mix bench bench/jsox_parser_bench.exs
