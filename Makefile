.ONESHELL:
.SILENT:
SHELL := /bin/bash
LC_NUMERIC := en_US.UTF-8 # make sure printf can parse floats from `bc` correctly

# this will be ran before any recipe runs
_ := $(shell mkdir -p obj bin)

nextpnr_root := /opt/nextpnr-xilinx

XRAY_DIR ?= /opt/prjxray
XRAY_UTILS_DIR := ${XRAY_DIR}/utils
XRAY_TOOLS_DIR := ${XRAY_DIR}/build/tools
EXEC_AS_XRAY := set -e && source "${XRAY_UTILS_DIR}/environment.sh" &&

db_root = ${nextpnr_root}/xilinx/external/prjxray-db/

help:
	@echo "Targets: flash, build-display, use-basys3"

.PHONY: flash
flash: use-basys3
flash: build-display
	openFPGALoader -b basys3 --bitstream bin/display.bit

.PHONY: build-display
build-display: use-basys3
build-display: bin/display.bit

obj/display-srcs: $(wildcard *.vhd)
	echo $^ > obj/display-srcs

.PRECIOUS: obj/%.json
obj/%.json: obj/%-srcs
	${INFO} Synthesizing... ${RST}
	${start_timer}
	yosys -q -m ghdl -p "ghdl $$(cat obj/$*-srcs) -e $*; synth_xilinx -flatten -abc9 -nobram -arch xc7 -top $*; write_json $@"
	${display_timer}

.PRECIOUS: obj/%.fasm
obj/%.fasm: obj/%.json %.xdc
	${INFO} Routing... ${RST}
	${start_timer}
	nextpnr-xilinx --quiet --chipdb bin/${pretty_dev}.bin --xdc $*.xdc --json $< --write obj/$*_routed.json --fasm $@
	${display_timer}

obj/%.frames: obj/%.fasm
	${INFO} Writing frames... ${RST}
	${start_timer}
	${EXEC_AS_XRAY} ${XRAY_UTILS_DIR}/fasm2frames.py --part ${board} --db-root ${db_root}/artix7 $^ > $@
	${display_timer}

bin/%.bit: obj/%.frames
	${INFO} Writing bitstream... ${RST}
	${start_timer}
	${EXEC_AS_XRAY} ${XRAY_TOOLS_DIR}/xc7frames2bit \
		--part_file ${db_root}/artix7/${board}/part.yaml --part_name ${board} \
		--frm_file $^ --output_file $@
	${display_timer}

.PHONY: setup-basys3-env
setup-basys3-env:
	$(eval board = xc7a35tcpg236-1)
	$(eval pretty_dev = basys3)

.PHONY: use-basys3
use-basys3: bin/basys3.bin
	${INFO} Using: basys3 ${RST}

.PRECIOUS: obj/%.bba
obj/%.bba: | setup-%-env
	${INFO} Writing $*"'"s blob asm ${RST}
	${start_timer}
	pypy3 ${nextpnr_root}/xilinx/python/bbaexport.py --device ${board} --bba obj/$*.bba
	${display_timer}

bin/%.bin: obj/%.bba
	${INFO} Assembling $*.bba ${RST}
	${start_timer}
	bbasm --l obj/$*.bba bin/$*.bin
	${display_timer}

.PHONY: clean clean-all
clean:
	-rm -f bin/display.bit obj/*
clean-all:
	-rm -rf obj/ bin/

board = no-board-assigned
pretty_dev = no-pretty-dev-assigned

INFO := @echo -e '\x1b[1;32m[INFO]'
RST := '\x1b[0m'

start_timer = $(eval start = $(shell date +'%s.%N'))
display_timer = printf "Took %.2f seconds\n" $$(date +"%s.%N - ${start}" | bc)