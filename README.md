# uapm

The μ adhoc package manager.

## What

Install a prebuilt-executable from an archive, such a github release zip.
The archive doesn't need to have any particular structure.

* Install a particular version of a tool in a developer or CI environment.
* Install the tool in a local directory, rather than system-wide. Different projects
may have different version requirements.
* Avoid building from source, or even having to clone a potentially huge github repo.

## Usage

See `uapm --help` for options

### Example

1. Create a file specifying the packages to install, example:
```json
[
    {
        "name": "swiftformat",
        "version": "0.50.8",
        "url": "https://github.com/nicklockwood/SwiftFormat/releases/download/0.50.8/swiftformat.zip",
        "checksum": "7156d128adcb9c1890935d04922d65a26e4014f009a0d5cdafad1a303796b3b2",
        "archiveExecutablePath": "swiftformat"
    }
]
```

2. Run `uapm install <packages-file>`

With the default options, this will result in the following files being written:
```sh
.bin/swiftformat-0.50.8/swiftformat
.bin/swiftformat  # symlink -> swiftformat-0.50.8/swiftformat
```
