#!/bin/bash
set -o xtrace -o pipefile
python3 examples/05_stable_diffusion/compile.py --token "$HF_TOKEN"
# clip is shared, unet and autoencoder are compiled to be bigger for img2img
#python3 examples/05_stable_diffusion/compile.py --img2img True --token $HF_TOKEN

find /root/.cache
TODAY=$(date '+%Y-%m-%d')
tar c ./tmp/CLIPTextModel ./tmp/UNet2DConditionModel ./tmp/AutoencoderKL -f "./ait-verdant-$TODAY.tar"
echo "$RCLONE_CONF" | base64 -d > rclone.conf
rclone -vv --config=rclone.conf copy --s3-chunk-size=256M "./ait-verdant-$TODAY.tar" r2:weights

# tar c /root/.cache -f ./hf-cache-ait-verdant-$TODAY.tar
# rclone -vv --config=rclone.conf copy --s3-chunk-size=256M ./hf-cache-ait-verdant-$TODAY.tar r2:weights
sleep 2d
