# Gemma 4 Optimized for Intel CPU and Intel GPU

The model is optimized for Intel hardware and distributed in Intermediate Representation (IR) on Huggingface.

```
hf download OpenVINO/gemma-4-E4B-it-int4-ov --local-dir gemma4-e4b-it-int4-ov
```

At startup OVMS (single model mode) creates the mediapipe graph file inside the model directory.
This directory is read-only when it is inside a component.
By adding a symlink with the file's name inside the model directory, pointing to /tmp, OVMS will follow the symlink during runtime and instead create the file in /tmp:

```
ln -s /tmp/graph.pbtxt ./gemma-4-E4B-it-int4-ov/graph.pbtxt
```