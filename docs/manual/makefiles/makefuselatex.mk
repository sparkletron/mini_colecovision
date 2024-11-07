PYTHON_APP=py/gen_fusesoc_latex_info.py
SRC_DIR=../../src/portable_coleco/
OUTPUT_DIR=src/fusesoc

FUSESOC_CORE_SRC=$(wildcard $(SRC_DIR)*.core)
LATEX_OUTPUT=$(notdir $(FUSESOC_CORE_SRC:.core=.tex))

.PHONY: clean

all: $(LATEX_OUTPUT)

%.tex: $(SRC_DIR)%.core
	@echo $@
	python3 $(PYTHON_APP) --core_file $< --prime_key_filter filesets --sub_key_filter files   	--list_name "Protable Coleco Glue File List"  --output $(OUTPUT_DIR)/$(addprefix files_,$@)
	python3 $(PYTHON_APP) --core_file $< --prime_key_filter filesets --sub_key_filter depend  	--list_name "Protable Coleco Glue Depenecies" --output $(OUTPUT_DIR)/$(addprefix depend_,$@)
	python3 $(PYTHON_APP) --core_file $< --prime_key_filter targets  --sub_key_filter description 	--list_name "Protable Coleco Glue Targets" 	--output $(OUTPUT_DIR)/$(addprefix targets_,$@)

clean:
	rm -rf $(OUTPUT_DIR)/*
