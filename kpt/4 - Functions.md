# Functions

## Declarative

Declarative via `Kptfile` with `kpt fn render`: 

1. Descends into each sub package, deepest first.
2. Executes mutators in order
  - output of previous is input of next
3. Executes validators in order
  - Input is the output of the last mutator
4. Repeats up to the top level package
5. Final output modifies the filesystem directly 

All functions take an optional `functionConfig` which is just a k8s `configMap` that can be stored elsewhere in the repo or passed to the function in the pipeline.

Likewise, you can pass optional selectors or exclusions similar to declaring a service.

- version
- kind
- name
- namespace
- annotations
- labels

For the lazy and dangerous:

- Can exec arbitrary bash functions rather than a container with the `exec` keyword.
  - not secure b/c system functions, duh
  - not as portable

## Imperative

Handy for one offs or executing from pipelines on `kpt` packages authored elsewhere.

```
kpt fn eval wordpress --image gcr.io/kpt-fn/set-namespace:v0.1 -- namespace=mywordpress
```

Selectors and exclusions have keyword arguments
