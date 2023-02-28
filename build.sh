#!/bin/bash
cd /AITemplate
set -o xtrace -o pipefail
python3 examples/05_stable_diffusion/compile.py --token "$HF_TOKEN"
#| ts '[%H:%M:%S]'
# clip is shared, unet and autoencoder are compiled to be bigger for img2img
#python3 examples/05_stable_diffusion/compile.py --img2img True --token $HF_TOKEN

LONG=$(nvidia-smi --query-gpu=gpu_name --format=csv|tail -1)
GPU=${GPU:-${LONG//[^[:alnum:]]/-}}

find /root/.cache/huggingface
TODAY=$(date '+%Y-%m-%d')
tar c ./tmp/CLIPTextModel/test.so ./tmp/UNet2DConditionModel/test.so ./tmp/AutoencoderKL/test.so -f "./ait-verdant-$TODAY-$GPU.tar"
echo "$RCLONE_CONF" | base64 -d > rclone.conf
rclone -vv --config=rclone.conf copy --s3-chunk-size=256M "./ait-verdant-$TODAY-$GPU.tar" r2:weights

rm -rf /root/.cache/pip
tar c /root/.cache -f ./hf-cache-ait-verdant-$TODAY.tar
rclone -vv --config=rclone.conf copy --s3-chunk-size=256M ./hf-cache-ait-verdant-$TODAY.tar r2:weights
sleep 2d
