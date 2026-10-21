# Nour Gad — Portfolio

**Live site:** https://nourgad.github.io/portfolio/

Personal portfolio of **Nour Gad** — PMP®-certified Senior RAN Engineer and Technical Project Manager (Ericsson MMEA), Google Cloud ACE and KCNA certified.

The site itself is a single, dependency-free HTML page. This repository also treats it as a production service — **Portfolio-as-Code** — to demonstrate the DevOps workflow end to end.

## What's inside

| Path | What it does |
|---|---|
| `docs/index.html` | The portfolio (served by GitHub Pages from `/docs`) |
| `Dockerfile` | Non-root NGINX image (`nginx-unprivileged`) on port 8080 with a health check |
| `deploy/docker/nginx.conf` | Security headers (CSP, X-Frame-Options, …), gzip, `/healthz` endpoint |
| `deploy/k8s/` | Kustomize set: restricted namespace, Deployment (probes, read-only root FS, dropped capabilities), Service, Ingress, HPA, PodDisruptionBudget |
| `deploy/terraform/` | Google Cloud Run + Artifact Registry + dedicated service account |
| `.github/workflows/ci.yml` | Lint HTML → link check → validate K8s (kubeconform) & Terraform → build → smoke test → Trivy scan → push to GHCR |

```
 push ──► lint + link check ──► docker build ──► smoke test ──► Trivy scan ──► ghcr.io
      └─► kubeconform + terraform validate
```

## Run locally

```bash
make run            # build and serve on http://localhost:8080
make test           # build, start, and check /healthz and the page
```

## Deploy to Kubernetes

```bash
kubectl apply -k deploy/k8s
kubectl -n portfolio rollout status deploy/portfolio
```

## Deploy to Google Cloud Run

```bash
cd deploy/terraform
cp terraform.tfvars.example terraform.tfvars   # set project_id
terraform init && terraform apply -target=google_artifact_registry_repository.portfolio
# push the image to the repository shown in `terraform output image_repository`, then:
terraform apply
```

## Contact

nour0gad@gmail.com · [LinkedIn](https://linkedin.com/in/nour-gad) · [GitHub](https://github.com/nourGAD)
