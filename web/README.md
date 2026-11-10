# Browser demo

The page starts v86's prepared **Windows 2000** demo and automatically launches
this repository's `kryz.bat`. It mounts a freshly built game floppy after restoring
the desktop snapshot. No installation, disk picker, or Windows image setting is
needed for the default demo. Windows XP is not used.

Browsers without the required JavaScript, WebAssembly, canvas, or layout support
show a plain HTML compatibility message and a link to the downloadable game.
That message also remains available when modules cannot be parsed or JavaScript
is disabled. Unsupported browsers do not download the emulator assets. The
fallback is available in English and Lithuanian; with JavaScript disabled, both
translations remain visible.

## Run locally

The shared build is a composite action in `.github/actions/build-web/`.
Local builds run it through [act](https://nektosact.com/) using
`.github/workflows/local-web.yml`. Install `act` and Docker with Linux
containers enabled, and start Docker before building. The first run downloads
the runner image and actions; `--bind` writes `dist/` back into this checkout.
`act` reads `GITHUB_TOKEN` from your environment or prompts for it, for the release
lookup action. CI uses its automatic read-only GitHub token.

Requires Node 24 for the local npm commands. The action installs packaging tools,
downloads and verifies ANSICON, renders the page, and creates the FAT12 floppy
using dosfstools and mtools. Release lookup uses the pinned
[cardinalby/git-get-release-action](https://github.com/cardinalby/git-get-release-action). Template rendering uses the pinned
[recih/template-render-action](https://github.com/recih/template-render-action)
action with the Mustache engine;
text preparation uses sed, iconv, and unix2dos. No local helper
package or npm install hook is used.

```sh
npm ci
npm start
```

Open http://localhost:8080. Windows restores and the game opens automatically,
without clicking a start button. Select a difficulty and play using the keyboard.
`npm start` runs the local workflow through `act` before starting the local server.
The same composite action runs in Pages deployment and dependency validation.
The build resolves
the latest published GitHub release and replaces `{{ latestReleaseZipUrl }}`
in `web/index.html.mustache` with its release ZIP archive URL. The deployed page makes no
release API requests. A failed lookup stops the build instead of publishing a
stale download link. Use `npm run build` to build without starting a server.
English is the default. The English and Lithuanian flag buttons in the left
sidebar restart the VM in the selected language; the selection is stored in the
page URL, so a plain URL always starts in English.
The sidebar, loading messages, mouse hints, and accessibility labels switch with
the game language. The game console opens maximized.
Click the machine or press Alt+M while it is focused to capture the mouse;
press Esc to release it. The focusable VM exposes an application role, a
translated accessible name, and input instructions. Browser pointer
capture requires that click, while machine startup remains automatic.
Refresh the page to reopen the game if you close its console. Refresh resets the VM;
changes are not saved to the upstream disk.

The static site is about 4 MB before HTTP compression. The upstream compressed
snapshot adds about 28.3 MiB on first launch; disk blocks are fetched in 256 KiB
chunks as Windows needs them. The logical disk is 2 GiB, not a 2 GiB initial
download. The snapshot requires 512 MiB guest RAM. This uses the upstream demo
as supplied, including its installed applications; it is not a stripped Windows
build. No UI framework, audio, or guest network relay is configured.

## Publishing

### Dependency updates and pull request CI

Dependabot checks npm dependencies and GitHub Actions every four months, on
January 1, May 1, and September 1 at 09:00 UTC. Security updates, when enabled
in GitHub, follow GitHub's separate security-update policy.

The `Dependency validation` workflow builds the site and validates the floppy by extracting and comparing every file
on pull requests to `master` and pushes to `master`. After a successful PR run,
a separate workflow enables squash auto-merge only for an open, non-draft PR
authored by `dependabot[bot]`, targeting `master` from this repository, with a
head commit matching the tested commit. The privileged workflow never runs PR
code or downloads its artifacts. Major updates are eligible too.

Enable **Allow auto-merge** and **Allow squash merging** in repository settings.
Protect `master` with **Test and build** as a required status check so GitHub
also enforces CI when merging, along with any other required checks/reviews.
Workflows become active after these files land on the default branch.
Merges using `GITHUB_TOKEN` do not trigger push workflows, so an automatically
merged update will be included in the next Pages deployment triggered by a
regular push.

To auto-merge GitHub Actions updates, create a fine-grained personal access
token restricted to this repository with **Contents: Read and write**,
**Pull requests: Read and write**, and **Workflows: Read and write**. Save it
as the repository **Actions secret** `DEPENDABOT_MERGE_TOKEN` (not a Dependabot
secret). A classic PAT with `repo` and `workflow` scopes also works, but grants
broader access. Set an expiration and rotate the secret before it expires.

The workflow uses this token only for the merge command; API reads continue
using `GITHUB_TOKEN`. Without the secret, non-workflow updates still use
`GITHUB_TOKEN`, while workflow updates fail with an explicit setup message.
Renamed and deleted workflow paths are checked too. A merge using the personal
access token also triggers the Pages push workflow normally. Do not store a
short-lived GitHub App installation token as this persistent secret.

### GitHub Pages

In GitHub **Settings → Pages → Build and deployment**, choose **GitHub Actions**.
The workflow builds and deploys only on pushes to `master`. The `github-pages`
environment must allow deployments from `master`. The workflow tests the FAT12 floppy and
independently validates it with `fsck.fat` and mtools.
The pipeline reads the Node version from `package.json` (`engines.node`), runs `npm ci --include=dev`, builds the
site, uploads `dist/`, configures Pages, then deploys using the built-in
`GITHUB_TOKEN`. No separate npm installation, PAT, or deploy key is required.
Other branches do not trigger this workflow. There are no pull request or
manual triggers. Active deployments are not cancelled by newer pushes.

Only `dist/` is uploaded. CI does not download, modify, or mirror Microsoft's
Windows disk or snapshot. v86 and firmware versions are pinned; upstream guest
URLs are external dependencies and may change or disappear. Browser requests
omit the referring page URL. The image host must allow cross-origin downloads.

## Game integration

The FAT12 floppy contains `kryz.bat`, both language CSVs, the game license,
and the unmodified x86 ANSICON 1.84 executable/DLL with its license.
The helper adds about 60 KB of files inside the same 1.44 MiB floppy. It enables
ANSI colors in the game console using `-p`, without a permanent registry
installation. X is cyan, O is magenta, and winning marks are green. ASCII board
characters remain compatible with the legacy console. If ANSICON is unavailable,
the game falls back to monochrome. The pinned archive and SHA-256 checksums are in [the build action](../.github/actions/build-web/action.yml).
The [upstream source](https://github.com/adoxa/ansicon/tree/v1.84) supplies the
zlib license, which is extracted by the build action and included in the built
site and game floppy. Version 1.84 is used because the 1.89 binaries target
Windows 5.1 and are rejected by Windows 2000.

The build also generates `Language/lt.txt`, an ASCII version of the
Lithuanian translation for Windows 2000. Accents are removed in this fallback;
the original UTF-8 source translation stays unchanged. The batch game uses an
optional language `.txt` file in legacy mode, otherwise falling back to English.
The page restores the snapshot, inserts this floppy, starts the CPU, and uses
Windows Run with `start /max` to launch `kryz.bat` directly in a maximized
command window with `/ASCII /COLOR /L en` or `/L lt`. The game detects and
enables the adjacent `ansicon.exe` and sizes the legacy console itself; no
launcher batch file is generated.

The initial desktop launch uses a short delay. On a particularly slow device,
wait for the desktop, then use Windows Run to launch `A:\kryz.bat /ASCII /COLOR /L en` if necessary. The status indicates
that launch was requested, not that Windows confirmed successful gameplay.

## Fixed v86 settings

The Windows 2000 disk/snapshot URLs and hardware settings are hardcoded in
`web/index.html.mustache`: 512 MiB RAM, 8 MiB VGA RAM, and a 2 GiB logical disk fetched
in 256 KiB chunks. There is no machine configuration file or CI variable setup.

## Windows image licensing

The preset follows the [upstream Windows 2000 profile](https://github.com/copy/v86/blob/master/src/browser/main.js)
and fetches the existing disk and snapshot directly from `i.copy.sh`. Availability
there does **not** establish Microsoft permission for our use, mirroring, or
redistribution. No such permission has been verified. The upstream project
identifies its older Windows images as abandonware obtained from WinWorld;
[WinWorld states that copyright remains with the owner](https://winworldpc.com/copyright).

The POSReady 2009 evaluation was also investigated. Its actual 120-day evaluation
terms limit use and prohibit publishing the software for others to copy; they
are not used as a distribution license for this demo. No Windows OS binaries,
product keys, trial resets, or activation workarounds are committed here. The
redistributable ANSICON utility is separate from the Windows operating system.
