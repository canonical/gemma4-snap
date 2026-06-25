#!/bin/bash

# OpenVINO E4B model
hf download OpenVINO/gemma-4-E4B-it-int4-ov --local-dir components/model-e4b-it-int4-ov/gemma4-e4b-it-int4-ov
ln -s /tmp/graph.pbtxt ./components/model-e4b-it-int4-ov/gemma4-e4b-it-int4-ov/graph.pbtxt