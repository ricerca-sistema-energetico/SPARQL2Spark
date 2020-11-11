# .PHONY defines parts of the makefile that are not dependant on any specific file
# This is most often used to store functions
.PHONY = help setup test

# Defines the default target that `make` will to try to make, or in the case of a phony target, execute the specified commands
# This target is executed whenever we just type `make`
.DEFAULT_GOAL = help

# The @ makes sure that the command itself isn't echoed in the terminal
help:
	@echo "---------------HELP-----------------"
	@echo "To build the project type make build"
	@echo "To setup the project type make setup"
	@echo "To test the project type make test"
	@echo "------------------------------------"

# Build wheel
build:
	python setup.py sdist bdist_wheel

# This installs the dependencies and the module using pip
setup: build
	@echo "Installing dependencies"
	pip install -r requirements.txt
	@echo "Installing SPARQL2Spark"
	pip install dist/SPARQL2Spark-0.0.1-py3-none-any.whl

test: setup
	pytest

docker-build:
	docker build -t python-test .
# This function uses pytest to test our source files
docker-test: docker-build
	docker run \
		-it \
		-v ${PWD}/SPARQL2Spark:/code/SPARQL2Spark \
		-v ${PWD}/tests:/code/tests \
		-v ${PWD}/Makefile:/code/Makefile \
		-v ${PWD}/requirements.txt:/code/requirements.txt \
		-v ${PWD}/setup.py:/code/setup.py \
		--network="test_network" \
		-w="/code" \
		python-test make test