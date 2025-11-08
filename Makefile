.PHONY: all deps build install clean

all: build

deps: .deps_installed

.deps_installed:
	jpm -l deps
	touch .deps_installed

build: deps
	jpm -l build

# Use $XDG_BIN_HOME if defined, otherwise default to ~/.local/bin
INSTALL_BIN ?= $(if $(XDG_BIN_HOME),$(XDG_BIN_HOME),$(HOME)/.local/bin)

install: build
	@echo "Installing hydratic to $(INSTALL_BIN) ..."
	@mkdir -p "$(INSTALL_BIN)"
	@cp build/hydratic "$(INSTALL_BIN)"
	@echo "Done!"

clean:
	jpm -l clean
	rm -rf jpm_tree build
