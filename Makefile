ROOTDIR = $(CURDIR)
IP_DIR = $(CURDIR)/ip
DESIGN_DIR = $(CURDIR)/designs

VITIS_HLS = vitis_hls
VIVADO = vivado

BUILD_DIR = $(CURDIR)/build
IP_BUILD_PATH := $(BUILD_DIR)/hls/
HW_BUILD_PATH := $(BUILD_DIR)/vivado/

CONFIG_TCL = $(ROOTDIR)/config.tcl

.PHONY: ip platform0 ndt clean

ip: ndt

ndt:
	mkdir -p $(IP_BUILD_PATH)
	cd $(IP_BUILD_PATH) && \
		$(VITIS_HLS) \
		-f $(IP_DIR)/ndt/ndt.tcl \
		-tclargs \
			$(IP_DIR) \
			$(CONFIG_TCL)
--p0:
	sed -i '/set platform/c\set platform_index 0' $(ROOTDIR)/config.tcl
--p1:
	sed -i '/set platform/c\set platform_index 1' $(ROOTDIR)/config.tcl

--vivado:
	mkdir -p $(HW_BUILD_PATH)
	cd $(HW_BUILD_PATH) && \
		$(VIVADO) -mode tcl \
		-source $(DESIGN_DIR)/project.tcl \
		-tclargs \
			$(ROOTDIR) \
			$(CONFIG_TCL)

platform0: --p0 --vivado
platform1: --p1 --vivado

clean:
	rm -rf $(BUILD_DIR)
