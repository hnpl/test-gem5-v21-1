#!/usr/bin/env sh

INFO_PREFIX="INFO: "
GEM5_FOLDER="./gem5"
GEM5_RESOURCES_FOLDER="./gem5-resources"
SPEC2006_ISO_PATH="/data1/CPU2006v1.0.1.iso"
SPEC2017_ISO_PATH="/data1/spec2017/cpu2017-1.1.0.iso"


GREEN='\033[0;32m'
NC='\033[0m'

print_info() {
    echo $GREEN$INFO_PREFIX $1 $NC;
}

# clone gem5-resources
if [ ! -d "$GEM5_RESOURCES_FOLDER" ] ; then
    print_info "cloning gem5-resources"
    git clone https://gem5.googlesource.com/public/gem5-resources;
fi
cd gem5-resources
git pull
git checkout develop
cd ../

# clone gem5
if [ ! -d "$GEM5_FOLDER" ] ; then
    print_info "cloning gem5"
    git clone https://gem5.googlesource.com/public/gem5;
fi
cd gem5;
git pull;
git checkout release-staging-v21-1;


# build m5
print_info "building m5"
cd util/m5;
/usr/bin/env python3 $(which scons) build/x86/out/m5;
cd ../../



# build X86
if [ ! -f "build/X86/gem5.opt" ]; then
    print_info "building X86/gem5.opt";
    yes | /usr/bin/env python3 $(which scons) build/X86/gem5.opt -j96;
fi

# build X86_MOESI_CMP_directory
if [ ! -f "build/X86_MI_example/gem5.opt" ]; then 
    print_info "building X86_MI_example/gem5.opt";
    echo "TARGET_ISA = 'x86'" > build_opts/X86_MI_example;
    echo "CPU_MODELS = 'AtomicSimpleCPU,O3CPU,TimingSimpleCPU'" >> build_opts/X86_MI_example;
    echo "PROTOCOL = 'MI_example'" >> build_opts/X86_MI_example;
    yes | /usr/bin/env python3 $(which scons) build/X86_MI_example/gem5.opt -j96;
fi

# build X86_MESI_Two_Level
if [ ! -f "build/X86_MESI_Two_Level/gem5.opt" ]; then
    print_info "building X86_MESI_Two_Level/gem5.opt";
    yes | /usr/bin/env python3 $(which scons) build/X86_MESI_Two_Level/gem5.opt -j96;
fi

# build X86_MOESI_CMP_directory
if [ ! -f "build/X86_MOESI_CMP_directory/gem5.opt" ]; then
    print_info "building X86_MOESI_CMP_directory/gem5.opt";
    echo "TARGET_ISA = 'x86'" > build_opts/X86_MOESI_CMP_directory;
    echo "CPU_MODELS = 'AtomicSimpleCPU,O3CPU,TimingSimpleCPU'" >> build_opts/X86_MOESI_CMP_directory;
    echo "PROTOCOL = 'MOESI_CMP_directory'" >> build_opts/X86_MOESI_CMP_directory;
    yes | /usr/bin/env python3 $(which scons) build/X86_MOESI_CMP_directory/gem5.opt -j96;
fi



# build SPEC 2006 disk image
cd gem5-resources/src/spec-2006/
if [ ! -f "../../../disk-images/spec-2006" ]; then
    print_info "building spec 2006 disk image"
    ln -s ../../../gem5 gem5;
    cd disk-image;
    wget https://releases.hashicorp.com/packer/1.6.5/packer_1.6.5_linux_amd64.zip;
    unzip packer_1.6.5_linux_amd64.zip;
    rm packer_1.6.5_linux_amd64.zip;
    cp $SPEC2006_ISO_PATH spec-2006/;
    ./packer build spec-2006/spec-2006.json;
    cd ../;
    mv "disk-image/spec-2006/spec-2006-image/spec-2006" ../../../disk-images/;
fi
cd ../../../;

# build SPEC 2017 disk image
cd gem5-resources/src/spec-2017/
if [ ! -f "../../../disk-images/spec-2017" ]; then
    print_info "building spec 2017 disk image"
    ln -s ../../../gem5 gem5;
    cd disk-image;
    wget https://releases.hashicorp.com/packer/1.6.5/packer_1.6.5_linux_amd64.zip;
    unzip packer_1.6.5_linux_amd64.zip;
    rm packer_1.6.5_linux_amd64.zip;
    cp $SPEC2017_ISO_PATH spec-2017/;
    ./packer build spec-2017/spec-2017.json;
    cd ../;
    mv "disk-image/spec-2017/spec-2017-image/spec-2017" ../../../disk-images/;
fi
cd ../../../




# download linux kernels
mkdir -p linux-kernels
cd linux-kernels
if [ ! -f "vmlinux-4.4.186" ]; then
    print_info "downloading vmlinux-4.4.186";
    wget http://dist.gem5.org/dist/v21-0/kernels/x86/static/vmlinux-4.4.186;
fi
if [ ! -f "vmlinux-4.9.186" ]; then
    print_info "downloading vmlinux-4.9.186";
    wget http://dist.gem5.org/dist/v21-0/kernels/x86/static/vmlinux-4.9.186;
fi
if [ ! -f "vmlinux-4.14.134" ]; then
    print_info "downloading vmlinux-4.14.134";
    wget http://dist.gem5.org/dist/v21-0/kernels/x86/static/vmlinux-4.14.134;
fi
if [ ! -f "vmlinux-4.19.83" ]; then
    print_info "downloading vmlinux-4.19.83";
    wget http://dist.gem5.org/dist/v21-0/kernels/x86/static/vmlinux-4.19.83;
fi
if [ ! -f "vmlinux-5.4.49" ]; then
    print_info "downloading vmlinux-5.4.49";
    wget http://dist.gem5.org/dist/v21-0/kernels/x86/static/vmlinux-5.4.49;
fi
cd ../


