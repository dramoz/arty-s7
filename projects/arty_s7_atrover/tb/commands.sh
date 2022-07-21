# Lint (with verilator)
make -f Verilator.mk lint

# run default test case
make clean; script -c "WAVES=1 make"
