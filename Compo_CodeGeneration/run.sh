#!/bin/sh
make re
./out/compo tests/basic.md
open ./out/result.html
