# Auto Stories

Auto generate widget preview to improve development experience.

> Attention that: current package is still in development,
> that it's strongly not recommended to use it in production.
> If you'd like to use it, please wait for a stable version after 1.0.0.

## Shared Options of `analysis_options.yaml`

see: https://dart.dev/tools/analysis#the-analysis-options-file

This package provides a template of `analysis_options.yaml` configurations,
which enables as much linter rules as possible to check the code strictly.
You can include such shared options
into your `analysis_options.yaml` file like this:

```yaml
include: package:auto_stories/analysis_options.yaml
```

or like this: (include more than one shared options, see
https://dart.dev/tools/analysis#including-shared-options)

```yaml
include:
  - package:auto_stories/analysis_options.yaml
  - ... # Other analysis options templates.
```
