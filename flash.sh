#!/bin/bash

TARGET_ELF_FILE=R2P2_PICO2-FLASH_MSC--20250713-dd30803.elf

SKIP_TEST=1 rake mrubyc:pico2:debug

#openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "adapter speed 1000" -c "program build_pico2/$TARGET_ELF_FILE verify reset exit"
