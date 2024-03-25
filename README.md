# mise-sops

[Sops](https://github.com/mozilla/sops) plugin for the
[Mise](https://github.com/jdx/mise) version manager.

## Install

```
sops plugin-add sops https://github.com/joshbode/mise-sops.git
```

## Environment Activation

Automatically activate the SOPS environment when entering the directory with the
following `.mise.toml`:

```toml
[tools]
sops = { version = "latest", filename = ".sops.env" }
```

## License

Licensed under the
[MIT license](https://github.com/joshbode/mise-sops/blob/main/LICENSE).
