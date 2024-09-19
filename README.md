Repisitory for the bachelor thesis of Arif Iscak.

# Implementation of Domain-Oriented Masking on a Small Scale Advanced Encryption Standard

## Goals

### Implementation of the DOM on a SSAES:
- [ ] Identify the operations in the provided implementation of the SSAES
- [ ] Identify the changes to be made to the SSAES.
- [ ] Create a new S-Box module to fit the DOM scheme.
- [ ] Adjust the SSAES to the changes and add the corresponding register stages.
- [ ] Simulate the design and verify its correctness.

### Port the implementation onto a Spartan 6 FPGA Sakura-G board:
- [ ] Identify potential changes to be made to successfully synthesize the design.
- [ ] Support the randomness input by adjusting the constraint files.
- [ ] Verify the output for correctness.

### Perform analysis following TVLA methodology:
- [ ] Modify the measurement script to support the new implementation.
- [ ] Set up the measurements.
- [ ] Record a sufficient amount of power traces.
- [ ] Perform the t-test on the data.

