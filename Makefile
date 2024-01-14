.ONESHELL:
.SILENT:
SHELL := /bin/bash

nextpnr_root = /opt/nextpnr-xilinx

XRAY_DIR ?= /opt/prjxray
XRAY_UTILS_DIR = ${XRAY_DIR}/utils
XRAY_TOOLS_DIR = ${XRAY_DIR}/build/tools
EXEC_AS_XRAY = set -e && source "${XRAY_UTILS_DIR}/environment.sh" &&

db_root = ${nextpnr_root}/xilinx/external/prjxray-db/

board = no-board-assigned
pretty_dev = no-pretty-dev-assigned

LOG = @echo -e '\x1b[1;32m[LOG]'
RST = '\x1b[0m'

help:
	@echo "Targets: flash, build-display, use-basys3"

.PHONY: flash
flash: use-basys3
flash: build-display
	openFPGALoader -b basys3 --bitstream bin/display.bit

.PHONY: build-display
build-display: use-basys3
build-display: bin/display.bit

.PHONY: set-display-srcs
set-display-srcs: $(eval SRCS = $(wildcard *.vhd))
	${LOG} Analysising files... ${RST}

.PRECIOUS: obj/%.json
obj/%.json: ${SRCS} | set-%-srcs
	${LOG} Synthesizing... ${RST}
	yosys -m ghdl -p "ghdl $^ -e $*; synth_xilinx -flatten -abc9 -nobram -arch xc7 -top $*; write_json $@"

.PRECIOUS: obj/%.fasm
obj/%.fasm: obj/%.json %.xdc
	${LOG} Routing... ${RST}
	nextpnr-xilinx --chipdb bin/${pretty_dev}.bin --xdc $*.xdc --json $< --write obj/$*_routed.json --fasm $@

obj/%.frames: obj/%.fasm
	${LOG} Writing frames... ${RST}
	${EXEC_AS_XRAY} ${XRAY_UTILS_DIR}/fasm2frames.py --part ${board} --db-root ${db_root}/artix7 $^ > $@

bin/%.bit: obj/%.frames
	${LOG} Writing bitstream... ${RST}
	${EXEC_AS_XRAY} ${XRAY_TOOLS_DIR}/xc7frames2bit \
		--part_file ${db_root}/artix7/${board}/part.yaml --part_name ${board} \
		--frm_file $^ --output_file $@

.PHONY: setup-basys3-env
setup-basys3-env: $(eval board = xc7a35tcpg236-1)
setup-basys3-env: $(eval pretty_dev = basys3)

.PHONY: use-basys3
use-basys3: basys3.bin
	${LOG} Using: basys3 ${RST}

.PRECIOUS: obj/%.bba
obj/%.bba: | setup-%-env
	${LOG} Writing $*"'"s blob asm ${RST}
	pypy3 ${nextpnr_root}/xilinx/python/bbaexport.py --device ${board} --bba obj/$*.bba

%.bin: obj/%.bba
	${LOG} Assembling $*.bba ${RST}
	bbasm --l obj/$*.bba bin/$*.bin

.PHONY: clean
clean:
	rm obj/*