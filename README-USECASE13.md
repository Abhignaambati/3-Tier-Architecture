# Use Case 13: Policy as Code for Kubernetes Deployments

## Goal

Use Conftest and OPA/Rego to block an unsafe Kubernetes Deployment, fix the manifest, and deploy the corrected workload.

## Lab boundary

- Kubernetes context: docker-desktop
- Namespace: policy-lab
- Deployment: claims-policy-demo
- Policy tool: Conftest
- Policy language: OPA/Rego
- Git branch: usecase/13-kubernetes-policy-as-code

No production or shared resources were used.

## Files

- policy/usecase13/deployment-security.rego: active non-root policy
- policy/usecase13/too-strict-team.rego.disabled: disabled noisy policy
- kubernetes/usecase13/namespace.yaml: lab namespace
- kubernetes/usecase13/deployment-unsafe.yaml: unsafe Deployment
- kubernetes/usecase13/deployment-fixed.yaml: corrected Deployment and Service
- usecase13-evidence/: command output and proof

## Selected policy

Every container in a Kubernetes Deployment must set securityContext.runAsNonRoot to true.

Running application containers as non-root reduces container privilege risk.

## Controlled failure

The unsafe Deployment did not define runAsNonRoot.

Conftest rejected it with a clear message identifying the Deployment, container, and required correction.

The unsafe manifest was not deployed.

## Corrected workload

The corrected Deployment includes:

- runAsNonRoot set to true
- Non-root user and group IDs
- Privilege escalation disabled
- Linux capabilities dropped
- RuntimeDefault seccomp profile
- CPU and memory requests and limits
- Readiness and liveness probes
- Application and environment labels

The fixed manifest passed Conftest and Kubernetes server-side validation.

## Deployment verification

The corrected workload was deployed in policy-lab.

Verification showed:

- Two pods Running and Ready
- runAsNonRoot was true
- runAsUser was 101
- allowPrivilegeEscalation was false
- Application health returned HTTP 200

## Too-strict policy exercise

A temporary policy required every Deployment to use the team label platform-core.

It blocked the secure claims Deployment only because its team label was claims.

The rule was too strict because application ownership can differ between teams. It created noise without addressing the selected security risk.

The noisy policy was disabled. The useful non-root policy remained active.

## Results

- Unsafe Deployment: blocked
- Corrected Deployment: allowed
- Kubernetes server dry run: passed
- Kubernetes rollout: successful
- Application health: HTTP 200
- Too-strict policy: identified and disabled
- Final active policy test: passed

## Policy balance

A useful policy should block a real risk, provide a clear correction, and avoid unnecessary restrictions.

The non-root policy protects the platform and gives developers an actionable message.

The exact team-label policy was noisy because it blocked normal work that was otherwise secure.

## Evidence

Evidence is stored in usecase13-evidence and includes:

- Unsafe policy failure
- Fixed policy success
- Too-strict policy failure
- Policy success after adjustment
- Kubernetes dry run
- Successful rollout
- Runtime security proof
- Application health proof
- Final completion proof

## Interview answer

I use policy as code to make platform requirements visible and repeatable before deployment. A good policy blocks a real risk, identifies the exact problem, and gives the developer a clear correction. I also test policies for false positives so the guardrail protects the platform without unnecessarily blocking normal work.
