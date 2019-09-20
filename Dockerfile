#FROM l.gcr.io/google/bazel:0.17.1
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
pkg-config zip g++ zlib1g-dev unzip python3 openjdk-11-jdk curl

RUN echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list

RUN curl https://bazel.build/bazel-release.pub.gpg | apt-key add -

RUN apt-get update && apt-get install -y bazel git

ADD . /opt/PRIVATE-JOIN-AND-COMPUTE

WORKDIR /opt/PRIVATE-JOIN-AND-COMPUTE

RUN bazel build :all \
--incompatible_disable_deprecated_attr_params=false \
--incompatible_depset_is_not_iterable=false \
--incompatible_new_actions_api=false \
--incompatible_no_support_tools_in_action_inputs=false