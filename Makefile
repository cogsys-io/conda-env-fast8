##
# Create fast8 (or fast8-based) conda environment.
#
# @file
# @version 0.3

PYTHON_VERSION?=3.8.8
ENV_NAME?=fast8
KERNELS_DIR:=${HOME}/.local/share/jupyter/kernels
HOME_DIR:=${HOME}

define CONDA_YAML
channels:
  - pytorch
  - conda-forge
  - defaults
  - bioconda
dependencies:
  - python=${PYTHON_VERSION}
  - pip
  - setuptools
  - gcc_linux-64
  - ipython
  - ipykernel
  - jupyter
  - ncurses
  - conda-forge::datalad
  - conda-forge::git-annex=*=alldep*
  - pytorch::pytorch=1.7.0=py3.8_cuda11.0.221_cudnn8.0.3_0
  - pytorch::torchvision=0.8.1=py38_cu110
  - cudatoolkit
  - cudnn
  - pip:
    - -r requirements.txt
endef
export CONDA_YAML

define PRINT_HELP_PYSCRIPT
import re, sys
from blessed import Terminal
term = Terminal()
for line in sys.stdin:
	match = re.match(r'^([0-9a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print(f"{term.bold_bright_blue}{target:36s}{term.normal} {help}")
endef
export PRINT_HELP_PYSCRIPT


help: ## display this help screen
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

write-yaml: ## write conda.yaml file
	@echo "$${CONDA_YAML}" > conda.yaml

list-envs: ## list conda envs
	@conda env list

create-env: write-yaml remove-env ## create conda env (defaults: ENV_NAME=fast8 PYTHON_VERSION=3.8.8)
	@conda env create --name ${ENV_NAME} --force --file "conda.yaml"

remove-env: ## remove conda env (same defaults as create-env)
	@conda env remove --name ${ENV_NAME}

all: create-env list-envs  ## create env and list all avalable envs

snapshot:  ## snapshot (same defaults as create-env)
	@mkdir -p "./arch"
	@bash -c 'source "$${HOME}/anaconda3/etc/profile.d/conda.sh" && conda activate ${ENV_NAME} && conda env export --name ${ENV_NAME} > "./arch/arch-$$(date +%Y%m%d-%H%M%S)-conda-export.yaml"'
	@bash -c 'source "$${HOME}/anaconda3/etc/profile.d/conda.sh" && conda activate ${ENV_NAME} && pip freeze >"./arch/arch-$$(date +%Y%m%d-%H%M%S)-pip-requirements.txt"'

list-kernels: ## list available jupyter kernels
	jupyter kernelspec list

add-kernelspec-local: ## Add local jupyter kernel spec
	@mkdir -pv "${KERNELS_DIR}/local_${ENV_NAME}/"
	@sed "s|ENV_NAME|${ENV_NAME}|g" kernels/local/kernel.json | \
	  sed "s|HOME_DIR|${HOME_DIR}|g" > "${KERNELS_DIR}/local_${ENV_NAME}/kernel.json"
	@cp -v imgs/logo*.png "${KERNELS_DIR}/local_${ENV_NAME}/"

add-kernelspec-remote-jiko-at-buka2: ## Add remote jupyter kernel spec for jiko at buka2
	@mkdir -pv "${KERNELS_DIR}/remote_${ENV_NAME}_jiko_at_buka2/"
	@sed "s|ENV_NAME|${ENV_NAME}|g" kernels/remote_jiko_at_buka2/kernel.json | \
	  sed "s|HOME_DIR|${HOME_DIR}|g" > "${KERNELS_DIR}/remote_${ENV_NAME}_jiko_at_buka2/kernel.json"
	@cp -v imgs/logo*.png "${KERNELS_DIR}/remote_${ENV_NAME}_jiko_at_buka2/"

# end
