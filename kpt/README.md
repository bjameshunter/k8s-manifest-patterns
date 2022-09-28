

Fetch and commit an existing KPT package:

```
kpt pkg get https://github.com/GoogleContainerTools/kpt/package-examples/nginx@v0.9
```

Run `kpt` functions to modify YAML paths.

```
kpt fn eval --image gcr.io/kpt-fn/search-replace:v0.1 -- by-path='spec.**.app' put-value=my-nginx
```
