# Filename: inventory_file_generator/Makefile
# Purpose: Make epic hosts and inventories files based on epic templates or previous epics.
# Arguments:
#		config: configuration file from which we initialize variables to create a new epic inventories and vars.
.PHONY: generate
generate: check-vars
	@sh epic_file_from_templates.sh $(config)

check-vars:
ifndef config
$(error config file is necessary to construct epic)
endif
