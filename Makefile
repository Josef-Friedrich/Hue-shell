INSTALL_DIR=/usr/local

all:
	@echo "Please run 'make install'"

install:
	mkdir -p /etc/hue-shell
	cp -r config/* /etc/hue-shell
	mkdir -p $(INSTALL_DIR)/lib/hue-shell
	cp base.sh $(INSTALL_DIR)/lib/hue-shell
	cp bin/hue* $(INSTALL_DIR)/

.PHONY: all install
