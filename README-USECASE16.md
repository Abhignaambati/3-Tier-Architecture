# Use Case 16: Detect and Fix Configuration Drift

## Goal

Detect differences between approved desired state and manually modified live state, review the exact difference, and restore the correct state through Argo CD and Terraform.

## Lab boundary

- Git branch: `usecase/16-configuration-drift`
- Kubernetes context: `docker-desktop`
- Kubernetes namespace: `claims-drift`
- Argo CD application: `claims-drift`
- AWS IAM role: `claims-usecase16-drift-lab-role`
- AWS region: `ap-south-1`

No shared production resources were modified.

## Tools used

- GitLab, Git, and GitHub
- Kubernetes and kubectl
- Helm
- Argo CD
- Terraform
- AWS CLI
- AWS IAM
- AWS Management Console

## Desired-state model

The repository is the approved source of truth. Helm defines the Kubernetes workload, Argo CD compares it with live Kubernetes state, and Terraform defines the AWS IAM role and its tags.

## Kubernetes and Argo CD drift

The `claims-drift` Argo CD application deployed the Claims workload into the `claims-drift` namespace. The healthy baseline showed `Synced` and `Healthy`, with one ready application replica.

A safe manual replica change was made directly in Kubernetes. Argo CD detected that live state differed from the desired state in Git. The difference was reviewed before correction. Because the manual change was only a controlled lab failure, Git was selected as the correct state. Argo CD synchronization restored the Deployment to the Git-defined replica count.

Final proof:

```text
claims-drift   Synced   Healthy
deployment.apps/claims-app   1/1   1   1
```

## AWS and Terraform drift

Terraform created the no-permission IAM role `claims-usecase16-drift-lab-role`. It had no attached permission policies and included these managed tags:

```text
ManagedBy   = Terraform
UseCase     = 16
Environment = lab
DriftStatus = ManagedByTerraform
```

The initial plan showed:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

The `DriftStatus` tag was then changed manually in the AWS Management Console to `ManualConsoleChange`. Terraform refreshed the live resource and detected the difference. The drift plan proposed one in-place correction and no destruction:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

The difference was reviewed before applying it. Terraform was selected as the correct desired state and restored `DriftStatus = ManagedByTerraform`. AWS CLI verification confirmed the corrected tag. The final Terraform plan reported that the infrastructure matched the configuration.

## Problems and recovery

### Argo CD repository authentication

Argo CD initially could not read the private GitLab repository because repository authentication was unavailable. The lab source was corrected to an accessible repository and the application was refreshed.

### Missing Kubernetes Secret

The workload initially could not start because `claims-app-secret` was missing. A lab-only Kubernetes Secret was created without storing its raw value in Git or evidence.

### Stale Terraform plan

Terraform rejected an older saved plan with `Saved plan is stale`. This prevented an outdated plan from being applied. A fresh plan was generated, reviewed, and applied.

### Expired AWS CLI session

The previous AWS CLI session had expired. AWS CLI was updated and `aws login` obtained short-term credentials. No access keys, session tokens, or authorization codes were stored in the repository.

## Evidence

The `usecase16-evidence` directory contains Argo CD status, Kubernetes workload status, Terraform plan and apply output, drift detection and correction output, the final clean plan, Terraform state and outputs, and AWS IAM tag verification.

## Result

Use Case 16 was completed successfully:

- Argo CD detected and corrected Kubernetes drift.
- Terraform detected and corrected AWS IAM tag drift.
- Differences were reviewed before correction.
- Argo CD finished `Synced` and `Healthy`.
- Kubernetes finished running and ready.
- Terraform finished with a clean no-change plan.
- No credentials were stored in Git.

## Interview answer

I treat drift as evidence that desired state and live state disagree. I inspect the exact difference, decide which state is correct, repair it through Git, Argo CD, or Terraform, and verify that the final state is clean and healthy.
