# Claims API Service Level Objective

## User-facing path

GET /api/claims

## Service Level Indicator

The SLI measures the proportion of Claims API requests that do not return an HTTP 5xx response.

SLI = successful requests / total requests

PromQL:

    1 - (
      sum(rate(claims_http_requests_total{path="/api/claims",status=~"5.."}[5m]))
      /
      clamp_min(
        sum(rate(claims_http_requests_total{path="/api/claims"}[5m])),
        0.001
      )
    )

## Service Level Objective

At least 99% of Claims API requests should succeed over a rolling 30-day period.

## Error budget

The allowed failure ratio is:

    100% - 99% = 1%

For every 10,000 requests, up to 100 requests may fail before the error budget
is exhausted.

The approximate time equivalent for a 30-day period is 7 hours and 12 minutes.
The primary SLO in this lab is request-based.

## Alert rule

ClaimsApiHighErrorRate fires when more than 5% of Claims API requests return
HTTP 5xx responses continuously for 30 seconds.

This is a user-impacting signal. CPU usage alone is not used because high CPU
does not necessarily mean that users are experiencing failures.
