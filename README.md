# Casanchess
[![Build Status](https://github.com/casanche/casanchess/actions/workflows/tests.yml/badge.svg)](https://github.com/casanche/casanchess/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Open-source [UCI](http://wbec-ridderkerk.nl/html/UCIProtocol.html)-compatible chess engine written from scratch in modern C++.

The project's ambition is to achieve high playing strength while maintaining a clean, well-structured, and understandable codebase.

The NNUE evaluation is trained on millions of chess positions, generated from self-play games and randomly created FENs. Each position was evaluated at depth 7 from its own evaluation function.

## Play it on Lichess!
Challenge the last version of the engine on:
<p align="center">
  <a href="https://lichess.org/@/Casanchess-NNUE">
    <strong>Play against Casanchess-NNUE</strong>
  </a>
</p>

## Getting started
The easiest way is to download the latest compiled release binaries from the **[Releases](https://github.com/casanche/casanchess/releases)** page.

Alternatively, you could compile the source code yourself using a C++23 compliant compiler:
```sh
git clone https://github.com/casanche/casanchess.git
cd casanchess

mkdir build && cd build
cmake ..
cmake --build . --parallel
```

### Configuration
For the NNUE evaluation to work, the `.nnue` file must be accessible:

* **Default**: Place the `.nnue` file in the working directory. Usually the same directory as the `casanchess` executable.
* **Custom path**: if the `.nnue` file is in a different location, set its path via the `NNUE_Path` UCI option.

The following UCI options are available:

* **``Hash``**: the transposition table size in MB. Default: 16MB
* **``Ponder``**: allows the engine to think on the opponent's time. Off by default.
* **``ClearHash``**: clears the transposition table.
* **``ClassicalEval``**: turn on to switch to the classical evaluation without NNUE. Off by default.
* **``NNUE_Path``**: Path to the NNUE file.

## Apple library build (macOS + iOS)
Build universal static libraries for:
- macOS (`arm64`, `x86_64`)
- iPhoneOS (`arm64`)
- iPhoneSimulator (`arm64`, `x86_64`)
- Mac Catalyst (`arm64`, `x86_64`)

Then package them into `casanchess.xcframework`:

```sh
./scripts/build-apple-libs.sh
```

Outputs are generated under:
- `artifacts/apple/libcasanchess-macos.a`
- `artifacts/apple/libcasanchess-iphoneos.a`
- `artifacts/apple/libcasanchess-iphonesimulator.a`
- `artifacts/apple/libcasanchess-maccatalyst.a`
- `artifacts/apple/casanchess.xcframework`

## Apple smoke Xcode project
Use the committed sample iOS + macOS smoke app project:

```sh
./scripts/generate-xcode-smoke.sh
```

The projects are:
- `examples/xcode-smoke/CasanchessSmoke iOS.xcodeproj`
- `examples/xcode-smoke/CasanchessSmoke macOS.xcodeproj`

Notes:
- The script uses the committed Xcode project and can build both iOS simulator + macOS targets when `BUILD_SMOKE=1`.
- For physical iPhone installs, open the project in Xcode and set a Development Team under Signing & Capabilities.

### Apple Syzygy tablebases
The Apple Swift package can bundle optional Syzygy WDL files for endgame
probing. Place `.rtbw` files under:

```sh
examples/xcode-smoke/Casanchess/Sources/Casanchess/syzygy/
```

Those files are intentionally ignored by git because tablebases are large. The
current Apple wrapper uses WDL probing during search; DTZ `.rtbz` files are not
used.

## Future roadmap
* Multi-thread implementation

## Special thanks
This project definitely would not be possible without the amazing chess programming community and the knowledge they openly share.
And to the many authors of chess engines, especially those with an inclination towards originality: keep up the work!

Contributions are welcome! Whether it's reporting bugs, suggesting new features, or improving the code, every contribution is appreciated.

Thanks to:
- [Talkchess.com](http://talkchess.com) forum. For the countless hours reading technical stuff.
- [Chess programming wiki](https://www.chessprogramming.org). Always an amazing resource of learning.
- [ShallowBlue](https://github.com/GunshipPenguin/shallow-blue). Clean C++ engine that provided initial inspiration.
- [cerebrum](https://github.com/david-carteau/cerebrum). Nice and simple NNUE implementation.