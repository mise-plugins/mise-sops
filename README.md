# mise-sops

[Sops](https://github.com/mozilla/sops) plugin for the
[Mise](https://github.com/jdx/mise) version manager.

Based on [asdf-sops](https://github.com/feniix/asdf-sops).

## Install

```bash
$ mise plugins install https://github.com/mise-plugins/mise-sops.git
```

## Environment Activation

Automatically activate the SOPS environment when entering the directory with the
following `.mise.toml`:

```toml
[tools]
sops = { version = "latest", filename = ".sops.env" }
```

If only some variables should be exported, then a name filter (separated by `:`)
can be applied:

```toml
[tools]
sops = {
  version = "latest",
  filename = ".sops.env",
  names = "GITHUB_TOKEN:PYPI_TOKEN"
}
```

Note: The names filter can be any
[bash-compatible regular expression](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html),
such as `[A-Z]+_TOKEN|AWS_[A-Z_]+` (matches are anchored between `^` and `$` but
can use `|` for alternation)

Additional filenames can be processed (last wins) by separating entries with
`:`, e.g.:

```toml
[tools]
sops = { version = "latest", filename = ".foo.env:.bar.env" }
```

## License

Licensed under the [MIT license](LICENSE).
