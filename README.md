<!-- markdownlint-configure-file {
  "MD013": {
    "code_blocks": false,
    "tables": false
  },
  "MD033": false,
  "MD041": false
} -->

<div align="center">

# sage

sage is a CLI assistant that allows you to use OpenAI's GPT-3 models right from your terminal.

[Getting started](#getting-started) •
[Installation](#installation) •
[Configuration](#configuration) •
[To do](#configuration)

</div>

## Getting started

### Prerequisites

* [curl](https://www.curl.se)
* [jq](https://stedolan.github.io/jq/)
* API Key from [OpenAI](https://beta.openai.com/account/api-keys)

<img src=tutorial.gif width=70% height=70%/>

```sh
sage "mass of sun"
```

## Installation

sage can be installed with the following one-liner:

```sh
curl -sS https://raw.githubusercontent.com/archelaus/sage/main/sage -o /usr/local/bin/sage
```
   
## Configuration

### Environment variables

Environment variables[^1] are used for configuration. They must be set before
sage is summoned

- `OPENAI_KEY`

[^1]: If you're not sure how to set an environment variable on your shell, check
out the [wiki](https://github.com/archelaus/sage/wiki/Setting-environment-variables-in-Linux).
