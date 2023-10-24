# export-action

This repo contains the GitHub Action that can be used to pull Superblocks application component changes from a connected GitHub repo to Superblocks.

See the [Source Control documentation](https://docs.superblocks.com/development-lifecycle/source-control/) for more information.

## Description

<!-- AUTO-DOC-DESCRIPTION:START - Do not remove or modify this section -->

Pull application-specific components source code from Superblocks

<!-- AUTO-DOC-DESCRIPTION:END -->

## Usage

```yaml
name: Sync application component changes from Superblocks
on: [push]

jobs:
  superblocks-pull:
    runs-on: ubuntu-latest
    name: Pull from Superblocks
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Pull
        uses: superblocksteam/export-action@v1
        id: pull
        with:
          token: ${{ secrets.SUPERBLOCKS_TOKEN }}
```

The above shows a standalone workflow. If you want to incorporate it as part of an existing workflow/job, simply copy the checkout and push steps into your workflow.

You can also pin the action to a [specific release version](https://github.com/superblocksteam/export-action/releases):

```yaml
      - name: Pull
        uses: superblocksteam/export-action@vx.y.z
```

### EU region

If your organization uses Superblocks EU, set the `domain` to `eu.superblocks.com` in the `Pull` step.

```yaml
      ...

      - name: Pull
        uses: superblocksteam/export-action@v1
        id: pull
        with:
          token: ${{ secrets.SUPERBLOCKS_TOKEN }}
          domain: eu.superblocks.com
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|    INPUT    |  TYPE  | REQUIRED |              DEFAULT              |                     DESCRIPTION                      |
|-------------|--------|----------|-----------------------------------|------------------------------------------------------|
| cli_version | string |  false   |            `"^1.1.0"`             |             The Superblocks CLI version              |
|   domain    | string |  false   |      `"app.superblocks.com"`      | The Superblocks domain where applications are hosted |
|    path     | string |  false   | `".superblocks/superblocks.json"` |   The relative path to the Superblocks config file   |
|     sha     | string |  false   |             `"HEAD"`              |              Commit to pull changes for              |
|    token    | string |   true   |                                   |         The Superblocks access token to use          |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->
