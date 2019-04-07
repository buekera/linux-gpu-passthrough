#!/bin/bash

# IDs of your GPU can be found with 'lspci -k'

gpu_id="<gpu_id>"
gpu_audio_id="<gpu_audio_id>"

basepath="/sys/bus/pci/drivers"

swap_to_nvidia() {
    echo -n "$gpu_id" > /sys/bus/pci/drivers/vfio-pci/unbind
    echo -n "$gpu_audio_id" > /sys/bus/pci/drivers/vfio-pci/unbind

    echo -n "$gpu_id" > /sys/bus/pci/drivers/nvidia/bind
    echo -n "$gpu_audio_id" > /sys/bus/pci/drivers/snd_hda_intel/bind

    nvidia-smi -i 1 -pm 1
}

swap_to_vfio-pci() {
    echo -n "$gpu_id" > /sys/bus/pci/drivers/nvidia/unbind
    echo -n "$gpu_audio_id" > /sys/bus/pci/drivers/snd_hda_intel/unbind

    echo -n "$gpu_id" > /sys/bus/pci/drivers/vfio-pci/bind
    echo -n "$gpu_audio_id" > /sys/bus/pci/drivers/vfio-pci/bind
}

is_driver_already_loaded() {
    if [ -d "$basepath/$1/$gpu_id" ]
    then
        echo "$1 is already loaded for device $gpu_id"
        exit 1
    fi
}

case "$1" in
  "nvidia")
    is_driver_already_loaded "nvidia"
    swap_to_nvidia
    ;;
  "vfio-pci")
    is_driver_already_loaded "vfio-pci"
    swap_to_vfio-pci
    ;;
  *)
    echo "Please specify either nvidia or vfio-pci to swap to."
    exit 1
    ;;
esac

