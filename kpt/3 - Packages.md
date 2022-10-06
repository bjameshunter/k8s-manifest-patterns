# Packages

Collection of YAML and `kpt` sub-packages.

`Kptfile` tracks upstream packages in git with the hash, location and path. Upstream not required.

## Rendering

1. Validates pre-conditions - legit `Kptfile`
2. Executes functions in package and sub-packages, depth first. Modifications occur in place
3. Guarantees post conditions - consistent formatting for example.

## Updating a packages

Make changes, commit. 

```
# simply adds ref v0.10 to Kptfile
kpt pkg update wordpress@v0.10
```

If you're not the publisher, `kpt` will make a resource based three-way merge between the original upstream commit, the new one, and any local changes.

## Getting sub packages

Make directories and `kpt init <sub-dir>`

or 

`kpt pkg get <location> <local-path>`

### Monorepo subpackages

Can be accommodated with a git tagging scheme that includes the path in the repo - ie.:

```
git tag packages/the-app/v0.1
```
