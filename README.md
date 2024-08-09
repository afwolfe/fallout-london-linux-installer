# Fallout London Proton Installer

An unofficial installer for [Fallout London](https://fallout4london.com/) for the Steam/Proton version of Fallout 4.

## Prerequisites

- p7zip
- [protontricks](https://github.com/Matoking/protontricks)
- [jq](https://github.com/jqlang/jq)
- [steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD)
- Steam for Linux with Fallout 4 installed
- Fallout London installed via GOG/Heroic Games Launcher

## Instructions

1. Ensure all prerequisites are met.
2. Run Fallout 4 at least once to ensure the game has created the expected files and directories (and Proton prefix)
3. Clone this repo with `git clone --recurse-submodules https://github.com/afwolfe/fallout-london-linux-installer.git`
   - The `--recurse-submodules` argument is important to clone the downgrader.
4. Run `./install-folon.sh` and answer all prompts.
5. Verify that the script completes successfully.
6. Install the FalloutLondon-$BUILD_ID.7z file using your preferred mod manager.
   - [rockerbacon/modorganizer2-linux-installer](https://github.com/rockerbacon/modorganizer2-linux-installer) - provides an automated way to install MO2 for Proton games
   - If using MO2 - ensure that you either disable profile-specific INIS or copy the recommended configurations into the profile
7. Launch the game via f4se_loader.exe

## Advanced Usage

You can run the downgrade unattended by setting all of the required CLI arguments and logging into steamcmd ahead of time.
The following arguments the script will attempt to autodetect if they are not specified:

- Fallout 4 installation (`--f4-app-path`)
- Fallout 4 Proton prefix (`--f4-prefix`)
- Fallout London path (`--folon-path`)

The other arguments must be provided or else the downgrader will prompt you for them when it gets to that part of the script.

```text
$ ./install-folon.sh --help
Usage: ./install-folon.sh [OPTIONS]

Options:
  -h, --help                                    Display this help message and exit
  --f4-app-path <path>                          Path to the Fallout 4 Steam installation directory
  --f4-prefix <path>                            Path for the Fallout 4 Proton prefix
  --folon-path <path>                           Path to the Fallout London installation directory
  --skip-downgrade                              Skip the Fallout 4 downgrader script
  -l <code>, --locale <code>                    Downgrader: Locale code for Fallout 4 depots (e.g., 'en', 'es', 'fr')
  -u <username>, --steam-username <username>    Downgrader: Your Steam username for steamcmd
  --owns-automatron                             Downgrader: Set this flag if you own the Automatron DLC
  --steamcmd-root <path>                        Downgrader: Specify steamcmd STEAMROOT. Defaults to ~/.steam/steamcmd
```

Ex:

```bash
steamcmd +login mysteamusername +quit
./install-folon.sh -l en -u mysteamusername --owns-automatron
```

## License

> Fallout London Proton Installer
> Copyright (C) 2024 afwolfe
>
> This program is free software: you can redistribute it and/or modify
> it under the terms of the GNU General Public License as published by
> the Free Software Foundation, either version 3 of the License, or
> (at your option) any later version.
>
> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> GNU General Public License for more details.
>
> You should have received a copy of the GNU General Public License
> along with this program.  If not, see <http://www.gnu.org/licenses/>.

This tool uses a modified version of [juliamertz/linux-fallout4-downgrader](https://github.com/juliamertz/linux-fallout4-downgrader) which is also available under GPLv3.

See [LICENSE](./LICENSE.md)

## References

- [Fallout London Release instructions](https://fallout4london.com/release/)
- [juliamertz/linux-fallout4-downgrader](https://github.com/juliamertz/linux-fallout4-downgrader)
