yes i know, the makefile is disgusting and over-engineered.
i'll learn how to use autoconf and/or cmake someday i swear.

# Dependencies

- a basys3 board
- [ghdl](https://github.com/ghdl/ghdl)
- [yosys](https://github.com/YosysHQ/yosys)
- [ghdl pluging for yosys](https://github.com/ghdl/ghdl-yosys-plugin)
- [Project XRAY](https://github.com/f4pga/prjxray) with patch to remove vivado requirement in utils/environment.sh
- [nextpnr-xilinx](https://github.com/gatecat/nextpnr-xilinx) todo: update to https://github.com/openXC7/nextpnr-xilinx

nextpnr-xilinx already includes a submodule pointing to prjxray-db, so no need to build it completely.

todo: split prjxray utils into some separate, slimmer thing, or maybe consolidate it into nextpnr-xilinx with submodule