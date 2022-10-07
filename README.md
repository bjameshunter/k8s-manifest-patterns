# Introduction

- Who here has managed a Kubernetes cluster before?
    - It's not going to change how or what I present, but I hear this is a good thing to know before presenting.

# What is lame about normal CI/CD?

Installing tools - helm and kubectl
Configuring permissions for each stage of pipeline to talk to its cluster
Configuring access to cloud platform
Security considerations of lots of certs or whatever floating around there
There is no visibility into the deployment without sending info back to CI/CD tool
Tempting to put app configuration in repo with code

# Concepts for managing Kubernetes Configuration

- Declarative - stored separately and idempotnent
- Uniform and reproducible
- Keeps config away from data and code
  - simplifies pipelines needing to determine what is code v. config
- Client operations do not need to know about storage or file structure
- `git commit` is _the_ method for making changes - audit, security, etc.
  - furthermore, any local `kubectl` commands just get clobbered when GitOps refreshes
- Not a pipeline, but can be the "CD" part of it

# Common tasks 

- Enforcing common labels
- Scaling or resource requests for different environments
- Factor out Azure Resource/Object IDs or AWS ARNs
- Conditional or global application of shared YAML snippets
- Insertion of YAML into a key or a list index
- Dirty, manual `kubectl` changes against a cluster
- Rolling back a config change
  - can be configured with CRDs
  - `git revert`
- Complete recreation of cluster for experiments or DR


# What Our Deployments Will Do 

1. Namespace `<env>-<tool>`
2. Some deployment
3. Customize file served based on the environment and tool

Maybe:

4. Ingress and associated DNS entry at `<tool>.<env>.host.com`
5. cert-manager deployment in each NS to do SSL for us.

# Key Benefits of Each

- Cluster control via branch policies rather than writing K8s roles
  - I gave engineers read-only access everywhere minus secrets

# Drawbacks 

- May be writing and creating artifacts that are not necessary with Helm 
  - Watching Image names and tags in a container repo
  - Connections to Git and Helm repos
  - Loads of CRDs that need permissions in your cloud and may operate in a somewhat opaque manner

## Flux

- Envs handled w/ combo of branches and customize overlays

Lo malo

- It's a lot of files - you will forget to add your file to `kustomization.yaml`
- Patching is ugly and verbose, strategic merge patches are often very redundant
- You will push YAML that won't compile or that violates KRM - up to you to hook in checks
- Mentally compiling paths seems like something that is easy to do, but it gets complicated
  - "Where is such-and-such resource set?" is not always easy to answer
 
Lo bueno

- Inventory control and pruning
- No tools or permissions to install in CI/CD agents (apart from writing to container reg)
- `HelmRelease` CRD generally does the right thing out of the box.
  - `watch kubectl hr -A` is generally what I do to for sanity
- Flux's `Kustomization` CRD allows handy levers to reconcile itself and insert dependencies to other `Kustomizations`.
- Image Updates

## Argo

- Envs handled w/ combo of branches and customize overlays

Handles plain YAML, Helm Charts, and Kustomize
Seems like image updates still happen via CI/CD, but Argo sucks them in 
Can send you an alert instead of reverting a manual change to what's in the repo.

Lo Bueno

- Inventory control and pruning
- What looks like a very comprehensive UI
- CRDs `AppProject` and `Application`
    - define a cluster and group of applications

Sources: 

[TechWorld with Nana](https://www.youtube.com/watch?v=MeU5_k9ssrs)

## Kpt

- Envs handled with function evaluations and in-line changes

Lo Malo

- 

Lo Bueno

- Inventory control and pruning
- Validation is treated as a first-class task
- 

# Final Observations

1. KPT has nice built in validator feature that would have saved me time before commits pushing to GitOps repo. I used a pre-commit hook that just made sure it made valid YAML.



