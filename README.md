<br />
<div align="center">
    <img src="docs/src/assets/logo-rounded.svg" alt="Logo" width="80" height="80">

  <h3 align="center">ECAP5-DSOC</h3>

  <p align="center">
    System-On-Chip implementation integrating ECAP5-DPROC
    <br />
    <a href="https://ecap5.github.io/ECAP5-DSOC/"><strong>Explore the docs »</strong></a>
    <br />
  </p>
</div>

## How to use the bootloader

The bootloader reads the `.elf` header located at `0x300000` in flash. In order for it to load a program, the program shall be placed at that address using the following command :

```bash
ecpprog -o 3M <binary>.elf -p
```

<!-- LICENSE -->
## License

Distributed under the GPL-3.0 license. See `LICENSE.txt` for more information.
