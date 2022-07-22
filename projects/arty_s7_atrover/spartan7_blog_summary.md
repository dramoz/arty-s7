****

# 🚎 Arty-S7-Rover (summary)

### Disclaimer

> ==**Build a project** with the Arty S7==, [7 Ways to Leave Your Spartan-6 FPGA](https://community.element14.com/technologies/fpga-group/w/documents/27537/7-ways-to-leave-your-spartan-6-fpga) [<img src="https://community.element14.com/e14/cfs/e14core/images/logos/e14_Profile_206px.png" alt="element14 Community" style="height:2em;" />](https://community.element14.com/) challenge.

The Arty-S7-Rover is a small functional autonomous vehicle based on the [Digilent Arty S7-50 board](https://digilent.com/reference/programmable-logic/arty-s7/start). The project was done for the [7 Ways to Leave Your Spartan-6 FPGA](https://community.element14.com/technologies/fpga-group/w/documents/27537/7-ways-to-leave-your-spartan-6-fpga) [<img src="https://community.element14.com/e14/cfs/e14core/images/logos/e14_Profile_206px.png" alt="element14 Community" style="height:2em;" />](https://community.element14.com/) challenge.

All the files are open-source, MIT license and can be downloaded from [<img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Logo.png" alt="GitHub Logo" style="height:1em;" />-<img src="https://avatars.githubusercontent.com/u/34524370?v=4" alt="img" style="height:1em;" />dramoz](https://github.com/dramoz/arty-s7)

### Summary

- What I learned about the Spartan-7 FPGA
- What I learned about VexRiscv
- What's next?

## Arty S7 - Spartan-7

When I started this journey, my knowledge of the Xilinx Spartan devices was what I got from my University courses, back in the day. I do most of my work at [<img src="https://www.eideticom.com/uploads/images/2019/07/11/eideticom-logo-03.svg" alt="Eideticom" style="height:1em" />]()as an HDL Verification Engineer, with Xilinx and open source tools like CoCoTB/Verilator.

The devices we target are [Ultrascale+ (Virtex/Kintex)](https://www.xilinx.com/products/silicon-devices/fpga/virtex-ultrascale-plus.html), with hundreds of thousands of logic resources - which are not "cheap" (as compared to a [Spartan-7](https://www.xilinx.com/products/silicon-devices/fpga/spartan-7.html), but you can always find something bigger and pricier [VERSAL](https://www.xilinx.com/products/silicon-devices/acap/versal.html) - hopefully one day I can put my hands on one of this). As for my own projects, I switch between ESP32 boards or the  [ZynQ Ultrascale+](https://www.xilinx.com/products/silicon-devices/soc/zynq-ultrascale-mpsoc.html).

The Spartan-7 was something I did not know I was missing. I was impressed by the available logic resources. DSP blocks and plenty of LUTs/FFs to have several RISC-V implementations in one small FPGA.

In terms of tools, Vivado ML is definitely a huge improvement over the old ISE. Things are easier to do and the results are acceptable.

The Arty S7 development board is a great starting point. It comes with a lot of IO ports and the necessary LEDs, and buttons, ... to do some productive work.

## VexRiscv

### Toolchain and C++ compile

`volatile`

## Future work

This is an ongoing project, and there are several features coming later. Among them, the next ones are:

- Arty-S7-Rover
  - RTL
    - Move the whole DC motor control to an RTL IP
    - Add one PWM for each RGB colour
    - Add an LCD
  - VexRiscv
    - add JTAG support for debugging and programming
    - add DDR support
    - add FPU (floating point unit)
    - Connect to WiFi (ESP32)
  - UART: add TX/RX FIFOs + improve handshaking (e.g. remove TX bit set)
  - Hardware
    - Add battery sensors
    - Check other DC motor drivers' options
- Tools
  - Better integration of verification tools: currently the verification process is a two-step, involving compiling the firmware (FW) and then running the simulation. Both should be integrated into a single `Makefile `that check for FW changes and compile as required.
  - Check the Vivado IP Integrator flow: I decided not to follow the usual IP integrator flow as I wanted to keep things as simple as possible given the allocated time for this project and the short deadline (~8 weeks when you only have nights and a couple of hours on weekends is not that much)

Finally, a multi-core with FreeRTOS VexRiscv implementation could be in the planning.

## Final Remarks

This was an interesting journey. As my work mostly goes around HDL Verification, I usually have little time to explore HDL and RTL coding. The experience was fruitful - I remembered and learned a lot during the process and it was interesting to see how much FPGAs have grown over the decades - especially in the low-cost devices. Having free tools is a plus, relatively cheap FPGA boards like the Arty-S7 are great not only for hobbyists but for any competent project.

I would like to thank [<img src="https://community.element14.com/e14/cfs/e14core/images/logos/e14_Profile_206px.png" alt="element14 Community" style="height:2em;" />](https://community.element14.com/), [<img src="https://cdn11.bigcommerce.com/s-7gavg/images/stencil/original/digilent-logo_ni_2021-260px_1_1627086513__23106.original.png" alt="Digilent" style="height:1em;" />](https://digilent.com/) and  [<img src="https://upload.wikimedia.org/wikipedia/commons/7/7c/AMD_Logo.svg" alt="img" style="height:1em;" />](https://www.amd.com/)|[<img src="https://www.xilinx.com/etc.clientlibs/site/clientlibs/xilinx/site-all/resources/imgs/products/xilinx-logo-product.png" alt="img" style="height:1em;" />](https://www.xilinx.com) for making these projects a possibility.

I would also like to thank the Open Community  [<img src="https://riscv.org/wp-content/uploads/2020/06/riscv-color.svg" alt="RISC-V International" style="height:1em;" />](https://riscv.org/)| [<img src="https://community.cadence.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-01-06/sifive_2D00_logo_2D00_v1.png" alt="img" style="height:1em;" />](https://www.sifive.com/), [<img src="https://www.veripool.org/img/verilator_256_200_min.png" alt="Logo" style="height:2em;" />](https://veripool.org/guide/latest/index.html) and [<img src="https://raw.githubusercontent.com/cocotb/cocotb-web/master/assets/img/cocotb-logo.svg" alt="CoCoTB" style="height:1em;" />](https://docs.cocotb.org/en/stable/). It would have not be possible to do any of this without the many hours spend on coding and debugging the tools.

------

 [<img src="https://github.githubassets.com/images/modules/logos_page/Octocat.png" alt="GitHub Octocat" style="height:2em;" /><img src="https://avatars.githubusercontent.com/u/34524370?v=4" alt="img" style="height:1em;" />dramoz](https://github.com/dramoz/arty-s7)

------

© Danilo Ramos, 2022
