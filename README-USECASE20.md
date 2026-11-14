# Use Case 20: Onboard a Second Application Using Platform Standards

## Objective

Onboard a small second application by reusing the same delivery and operational
standards used by the existing platform.

Application details:

- Platform: ClaimsLab
- Application: claims-status-api
- Environment: dev
- Kubernetes namespace: claimslab-status-dev
- Branch: usecase/20-platform-onboarding
- Harbor project: claimslab
- Harbor repository: claims-status-api
- Image tag: d07031db9967
- Vault path: secret/claimslab/dev/claims-status-api
- Argo CD application: claimslab-status-api-dev

## Tools Used

- GitLab and GitHub for source control and branch evidence
- Jenkins for test, build, scan, tag, and push automation
- Docker for container image creation
- Trivy for image vulnerability scanning
- Harbor for private image storage
- Helm for reusable Kubernetes packaging
- Vault for application secret storage
- Kubernetes for workload execution
- Argo CD for GitOps deployment
- Prometheus for application metrics
- Grafana for the operational dashboard
- Alloy and Loki for centralized structured logs
- PrometheusRule for alert coverage

## Delivery Flow

The completed delivery flow is:

    Git branch
        -> Jenkins tests
        -> Docker image build
        -> Trivy scan
        -> Harbor push
        -> Helm values
        -> Argo CD synchronization
        -> Kubernetes deployment
        -> Prometheus metrics
        -> Grafana dashboard
        -> Alloy and Loki logs
        -> Prometheus alert

## Application

The application provides:

- `/health`: application health
- `/api/status`: public application status
- `/api/secure-status`: secret-dependent status
- `/metrics`: Prometheus metrics

Structured logs include:

- service
- environment
- version
- request ID
- method
- path
- HTTP status
- request duration

## Jenkins Pipeline

The Jenkins pipeline is stored at:

    jenkins/usecase20/Jenkinsfile

Pipeline stages include:

1. Checkout
2. Unit Test
3. Build Image
4. Scan Image
5. Push to Harbor
6. Pipeline Proof

The successful application image is:

    harbor.example.com:80/claimslab/claims-status-api:d07031db9967

Harbor digest:

    sha256:9166ca7cbb66332cffb0167ec09d48ae6242d42e3b170a5b50634b662e8d548f

## Helm Packaging

The Helm chart is stored under:

    helm/claims-status-api/

It contains:

- Deployment
- Service
- ServiceMonitor
- PrometheusRule
- Common values
- Development values
- Resource requests and limits
- Health and readiness probes
- Harbor imagePullSecret reference
- Kubernetes Secret reference

Render the chart with:

    helm template claims-status-api \
      helm/claims-status-api \
      -f helm/claims-status-api/values-common.yaml \
      -f helm/claims-status-api/values-dev.yaml

## Vault Secret Handling

The application token is stored at:

    secret/claimslab/dev/claims-status-api

The Kubernetes Secret is:

    claims-status-api-secret

Only the secret name and key were saved as evidence. Raw secret values were not
printed or committed.

The application reads the token through the `APP_API_TOKEN` environment
variable and Kubernetes `secretKeyRef`.

Vault is running in development mode with in-memory storage. A Docker restart
can erase the Vault data. For this lab, the value must then be recreated and
synchronized again. Production Vault must use persistent storage and approved
authentication.

## Argo CD Deployment

The Argo CD Application is stored at:

    argocd/claims-status-api-dev.yaml

Final status:

    Sync: Synced
    Health: Healthy

The private GitLab source initially produced an authentication error. The lab
Argo CD Application was changed to use the public GitHub branch because no
GitLab repository credential was configured in Argo CD.

A production environment should configure an Argo CD repository credential
instead of changing the repository source.

## Harbor and Kubernetes Pull Access

The Harbor project is private, so Kubernetes uses:

    imagePullSecrets:
      - name: harborpull

Docker Desktop Kubernetes also required containerd routing for the local Harbor
hostname. After Docker Desktop restarts, verify the Harbor containerd
configuration before troubleshooting the application code.

## Metrics and Dashboard

Prometheus collects metrics through the Helm ServiceMonitor.

Important metrics include:

    up{namespace="claimslab-status-dev",service="claims-status-api"}

    claims_status_http_requests_total

    claims_status_http_request_duration_seconds

Grafana dashboard:

    ClaimsLab Status API - Dev

Dashboard panels:

1. Claims Status API Target
2. Claims Status API Request Rate
3. Claims Status API Error Ratio

## Centralized Logging

Log flow:

    Application stdout
        -> Kubernetes pod logs
        -> Grafana Alloy
        -> Loki
        -> Grafana Explore

The original Alloy configuration collected only `logging-lab`.

Original filter:

    regex = "logging-lab"

Corrected filter:

    regex = "(logging-lab|claimslab-status-dev)"

Successful Loki query:

    {namespace="claimslab-status-dev"} | json | request_id="UC20-LOG-002"

The result contains the expected service, environment, version, request ID,
status, and message fields.

## Alert Test

Alert:

    ClaimsStatusApiHighErrorRate

The alert uses the ratio of HTTP 5xx responses to all application requests.

A controlled test temporarily removed the usable application token, causing
`/api/secure-status` to return HTTP 503. Sustained requests caused the rule to
enter the firing state.

The secret was restored from Vault, the application pod was restarted, and the
secure endpoint returned HTTP 200 again. The alert then became inactive.

This proved both alert firing and recovery.

## Final Verification

Final platform state:

- Jenkins pipeline succeeded
- Image exists in Harbor
- Helm chart renders successfully
- Vault secret is readable
- Kubernetes Secret contains the expected key
- Deployment is 1/1 Ready
- Pod is Running
- Service is available
- Argo CD is Synced and Healthy
- Prometheus target is available
- Grafana dashboard is populated
- Loki can search the structured application log
- Alert fired during controlled failure
- Alert resolved after recovery

## Important Evidence

Evidence is stored under:

    usecase20-evidence/

Key files include:

- Jenkins success time and commit
- Harbor digest and artifact metadata
- Helm lint and render output
- Vault masked proof
- Kubernetes secret masked proof
- Argo CD final status
- Kubernetes final status
- Prometheus metric queries
- Grafana dashboard JSON
- Alloy namespace correction
- Loki structured-log query
- Alert firing state
- Alert recovery state
- Health and secure-endpoint recovery proof

## Handover Procedure

A new team member should:

1. Start Docker Desktop.
2. Confirm Kubernetes is Ready.
3. Start Harbor and verify its health endpoint.
4. Start Vault and verify the approved secret path.
5. Confirm Jenkins credentials and run the pipeline.
6. Verify the image tag in Harbor.
7. Render and lint the Helm chart.
8. Confirm the Kubernetes pull secret exists.
9. Apply or synchronize the Argo CD Application.
10. Wait for the Deployment to become Ready.
11. Test `/health` and `/api/secure-status`.
12. Confirm Prometheus collects the application metrics.
13. Open the Grafana dashboard.
14. Generate a request ID and search it in Loki.
15. Verify the Prometheus alert rule is present.

## Troubleshooting Lessons

The controlled problems and fixes were:

- GitLab authentication failure in Argo CD:
  corrected the repository source for the lab.
- Harbor ImagePullBackOff:
  restored Harbor routing and the imagePullSecret.
- Missing Loki application logs:
  expanded the Alloy namespace filter.
- Vault data missing after restart:
  recreated and resynchronized the lab secret.
- High error-rate alert:
  restored the application secret from Vault and verified recovery.

## Interview Answer

I onboarded a second application by reusing platform standards rather than
building a separate delivery path. Jenkins tested, scanned, built, and pushed
the image to Harbor. Helm packaged the workload, Vault supplied the secret,
Argo CD deployed it to Kubernetes, and Prometheus, Grafana, Alloy, and Loki
provided metrics, dashboards, alerts, and searchable logs. I also tested
controlled failures and proved recovery.
