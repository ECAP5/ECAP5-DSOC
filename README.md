<p float="left">
<a href="https://ecap5.github.io/ECAP5-DSOC/report.html"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fgist.githubusercontent.com%2Fcchaine%2F9e5dd2096835bc1230f8a6e787f9f7a7%2Fraw%2Ftest-result-badge.json?"/></a>
<a href="https://ecap5.github.io/ECAP5-DSOC/report.html"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fgist.githubusercontent.com%2Fcchaine%2F9e5dd2096835bc1230f8a6e787f9f7a7%2Fraw%2Ftraceability-result-badge.json?"/></a>
</p>

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
