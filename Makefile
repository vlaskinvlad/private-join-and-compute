IMAGE_NAME = pjc
GIT_VERSION := $(shell git describe --abbrev=7 --dirty --always --tags)


DOCKER = docker


docker:
	${DOCKER} build -t ${IMAGE_NAME} .
	${DOCKER} tag ${IMAGE_NAME} ${GIT_VERSION}

build:
	bazel build :all \
	--incompatible_disable_deprecated_attr_params=false \
	--incompatible_depset_is_not_iterable=false \
	--incompatible_new_actions_api=false \
	--incompatible_no_support_tools_in_action_inputs=false

server: 
	bazel-bin/server --server_data_file=/tmp/dummy_server_data.csv --message_size=12342134 --compression_level=2 --port=gcp:10501

client: 
	bazel-bin/client --client_data_file=/tmp/dummy_client_data.csv --paillier_modulus_size=1586 --port=gcp:10501