

# Prerequisites

SpinalHDL (VexRISCV)

```bash
# Scala
cd ~/tools
curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > cs && chmod +x cs && ./cs setup

sudo reboot

# VexRiscv Generator
cd ~/repos
git clone git@github.com:SpinalHDL/VexRiscv.git
cd ~/repos/VexRiscv/
sbt "runMain vexriscv.demo.VexRiscvAxi4WithIntegratedJtag"

```

