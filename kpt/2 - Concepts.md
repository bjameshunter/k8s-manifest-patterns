# KPT Fundamental Concepts

Primary feature 

- Packages of parameterizable manifests
- in-place config transformation rather than out-of-place.
- validation is supported at a lower level

## Toolchain

### CLI

- Supports fetching and updating Packages
- Deployment operations via direct application or GitOps
- Inventory for pruning, status, observability

### Function SDKs

- Transform and valiate the Kubernetes Resource Model input and output
- SDKs in Go, TypeScript and "Starlark"
- Function catalog of tested, commonly needed transformations and validations

### Package Orchestrator

- CRUD on packages similar to ops on live K8s API

### Config Sync

- Integrated GitOps reference implementation
- Leverages `kustomize` for rendering manifests on the fly

## Packages

A directory with a YAML file called `Kptfile`. May contain subpackages.
Fetch from upstream git repo, customize, apply. Designed to allow local changes to be easily merged to changes in the upstream.

If you point `kpt get` to a directory of manifests, it will treat it as a package and generate a local `Kptfile` for you.

## Workflow

Kpt docs describe it as:

1. get `kpt get ...`
2. explore
3. edit
    - render
    - -> edit 

As mentioned, you may want to update the package from the upstream source. Uses a resource based merge strategy, not line based as in git.

1. create with `kpt pkg init`
3. edit
    - render
    - -> edit 

Either way, you get rendered manifests that you can apply to a cluster.

1. Initialize - `kpt live init`
2. Preview - `kpt live apply --dry-run` 
  - observe expected apply and pruning
3. Apply - `kpt live apply`
4. Observe - `kpt live status`

## Functions

Containerized operations on the KRM.

- Label all resources matching some criteria
- Inject sidecars
- Some bulk transform

Standarized input and output allows them to be chained.

Two ways to run:

- `kpt fn render` - declarative, looks at pipeline declared in `Kptfile` and associated function configs.
- `kpt fn eval` - imperative, at CLI, to allow fiddling with function configs before codifying in `Kptfile`

