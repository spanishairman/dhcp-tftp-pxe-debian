#!/bin/bash
virt-install \
	--connect qemu:///system \
	--pxe \
        --osinfo debian12 \
	--name  debian12-2 \
	--boot uefi \
	--vcpus 8 \
	--memory 1024 \
        --disk size=20,pool=pool \
	--network network=vagrant-libvirt-central1,model=virtio,driver.iommu=on \
        --graphics spice \
