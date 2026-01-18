#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_NAME = seismic-anomalies-krr-assistant
PYTHON_VERSION = 3.12
PYTHON_INTERPRETER = python3.12
VENV_NAME = .venv

#################################################################################
# COMMANDS                                                                      #
#################################################################################


## Install Python dependencies
.PHONY: requirements
requirements:
	@echo ">>> Installing requirements..."
	$(VENV_NAME)/bin/pip install --upgrade pip
	$(VENV_NAME)/bin/pip install -U pip setuptools wheel
	$(VENV_NAME)/bin/pip install -r requirements.txt
	@echo ">>> Requirements installed!"	

## Activate environment (display command)
activate:
	@echo ">>> To activate virtual environment, run:"
	@echo ">>> source $(VENV_NAME)/bin/activate"

## Deactivate environment (display command)
deactivate:
	@echo ">>> To deactivate virtual environment, run:"
	@echo ">>> deactivate"



## Delete all compiled Python files
.PHONY: clean
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete


## Lint using ruff (use `make format` to do formatting)
.PHONY: lint
lint:
	ruff format --check
	ruff check

## Format source code with ruff
.PHONY: format
format:
	ruff check --fix
	ruff format





## Set up Python interpreter environment
.PHONY: create_environment
create_environment:
	@echo ">>> Creating virtual environment..."
	$(PYTHON_INTERPRETER) -m venv $(VENV_NAME)
	@echo ">>> Virtual environment created in ./$(VENV_NAME)/"
	@echo ">>> To activate run: source $(VENV_NAME)/bin/activate"
	@echo ">>> Then install dependencies with: make requirements"	



#################################################################################
# PROJECT RULES                                                                 #
#################################################################################


## Make dataset
.PHONY: data
data: requirements
	$(PYTHON_INTERPRETER) seismic_anomalies_krr_assistant/dataset.py


#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys; \
lines = '\n'.join([line for line in sys.stdin]); \
matches = re.findall(r'\n## (.*)\n[\s\S]+?\n([a-zA-Z_-]+):', lines); \
print('Available rules:\n'); \
print('\n'.join(['{:25}{}'.format(*reversed(match)) for match in matches]))
endef
export PRINT_HELP_PYSCRIPT

help:
	@$(PYTHON_INTERPRETER) -c "${PRINT_HELP_PYSCRIPT}" < $(MAKEFILE_LIST)
