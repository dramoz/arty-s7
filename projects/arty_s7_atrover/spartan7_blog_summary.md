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

## Spartan-7

When I started this journey, my knowledge of the Xilinx Spartan devices was what I got from my University courses, back in the day. I do most of my work at [<img src="https://www.eideticom.com/uploads/images/2019/07/11/eideticom-logo-03.svg" alt="Eideticom" style="height:1em" />]()as an HDL Verification Engineer, with Xilinx and open source tools like CoCoTB/Verilator.

The devices we target are [Ultrascale+ (Virtex/Kintex)](https://www.xilinx.com/products/silicon-devices/fpga/virtex-ultrascale-plus.html), with hundreds of thousands of logic resources - which are not "cheap" (as compared to a [Spartan-7](https://www.xilinx.com/products/silicon-devices/fpga/spartan-7.html), but you can always find something bigger and pricier [VERSAL](https://www.xilinx.com/products/silicon-devices/acap/versal.html)). As for my own projects, I switch between ESP32 boards or the  [ZynQ Ultrascale+](https://www.xilinx.com/products/silicon-devices/soc/zynq-ultrascale-mpsoc.html).

The Spartan-7 was something I did not know I was missing.

I was impressed by the available logic resources.

In terms of tools, Vivado ML is definitely a huge improvement over the old ISE. Things are easier to do and the results are acceptable.

## VexRiscv

## Future work

This is an ongoing project, and there are several features coming later. Among them, the next ones are:

- Arty-S7-Rover
  - VexRiscv
    - add JTAG support for debugging and programming
    - add DDR support
    - add FPU (floating point unit)
  - Hardware
    - Add battery sensors
    - Check other DC motor drivers options
- Tools
  - Better integration of verification tools: currently the verification process is a two-step, involving compiling the firmware (FW) and then running the simulation. Both should be integrated into a single `Makefile `that check for FW changes and compile as required.
  - Check the Vivado IP Integrator flow: I decided not to follow the usual IP integrator flow as I wanted to keep things as simple as possible given the allocated time for this project and the short deadline (~8 weeks when you only have nights and a couple of hours on weekends is not that much)



## Final Remarks
