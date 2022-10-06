# Introduction

- Who here has managed a Kubernetes cluster before?
    - It's not going to change how or what I present, but I hear this is a good thing to know before presenting.

# Concepts for managing Kubernetes Configuration

- Declarative - stored separately and idempotnent
- Uniform and reproducible
- Keeps config away from data and code
- Client operations do not need to know about storage or file structure

# Common tasks 

- Enforcing common labels
- Scaling for different environments
- Factor out Azure Resource/Object IDs or AWS ARNs
- Conditional or global application of shared YAML snippets
- Insertion of YAML into a key or a list index

# What Our Deployments Will Do 

1. Namespace `<env>-<tool>`
2. nginx deployment
3. Customize file served based on the environment and tool

Maybe:

4. Ingress and associated DNS entry at `<tool>.<env>.host.com`
5. cert-manager deployment in each NS to do SSL for us.

# Key Features of Each

## Flux

## Argo

## Kpt

# Final Observations

1. KPT has nice built in validator feature that would have saved me time before commits pushing to GitOps repo. I used a pre-commit hook that just made sure it made valid YAML.

