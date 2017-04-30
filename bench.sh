#!/bin/bash
MIX_ENV=bench mix compile
MIX_ENV=bench mix bench
# MIX_ENV=bench mix bench bench/jsox_parser_bench.exs
