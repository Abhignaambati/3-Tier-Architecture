package main

import rego.v1

container_runs_as_non_root(container) if {
    container.securityContext.runAsNonRoot == true
}

deny contains message if {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container_runs_as_non_root(container)

    message := sprintf(
        "Deployment %q container %q must set securityContext.runAsNonRoot: true",
        [input.metadata.name, container.name],
    )
}
