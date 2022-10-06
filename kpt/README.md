# KPT basics

Fetch and commit an existing KPT package:

```
kpt pkg get https://github.com/GoogleContainerTools/kpt/package-examples/nginx@v0.9
```

Run `kpt` functions to modify YAML paths.

```
kpt fn eval --image gcr.io/kpt-fn/search-replace:v0.1 -- by-path='spec.**.app' put-value=my-nginx
```

Note the `pipeline` section of the `Kptfile`. It currently just validates resources according to their OpenApi schema.

A common mutator adds labels to all resources in the package.

Render the manifests:

```
kpt fn render
```

The new labels can be seen in the manifests.

Init adds metadata to the `Kptfile`

```
kpt init
```

The manifests can then be applied as follows:

```
kpt live apply --reconcile-timeout=15m
```

Add and commit your own customizations. You may also want to bring in upstream changes to the package:

```
kpt pkg update @v0.10
```

Destroy Kpt managed resources:

```
kpt live destroy
```

