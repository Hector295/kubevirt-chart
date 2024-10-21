# Variables
LOCALBIN ?= $(shell pwd)/bin
HELMIFY ?= $(LOCALBIN)/helmify
CHART_NAME ?= kubevirt-chart
MANIFESTS_DIR ?= $(shell pwd)/manifiestos

# Get the latest stable KubeVirt version
KUBEVIRT_VERSION ?= $(shell curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)

# Ensure the binary and manifests directories exist
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

$(MANIFESTS_DIR):
	mkdir -p $(MANIFESTS_DIR)

# Download helmify
.PHONY: helmify
helmify: $(HELMIFY)
$(HELMIFY): $(LOCALBIN)
	test -s $(LOCALBIN)/helmify || GOBIN=$(LOCALBIN) go install github.com/arttor/helmify/cmd/helmify@latest

# Download KubeVirt manifests
.PHONY: download-manifests
download-manifests: $(MANIFESTS_DIR)
	@echo "Downloading KubeVirt manifests for version $(KUBEVIRT_VERSION)..."
	@curl -sSL "https://github.com/kubevirt/kubevirt/releases/download/$(KUBEVIRT_VERSION)/kubevirt-operator.yaml" -o "$(MANIFESTS_DIR)/kubevirt-operator.yaml"
	@curl -sSL "https://github.com/kubevirt/kubevirt/releases/download/$(KUBEVIRT_VERSION)/kubevirt-cr.yaml" -o "$(MANIFESTS_DIR)/kubevirt-cr.yaml"
	@cat "$(MANIFESTS_DIR)/kubevirt-operator.yaml" "$(MANIFESTS_DIR)/kubevirt-cr.yaml" > "$(MANIFESTS_DIR)/combined-manifests.yaml"
	@sed -i 's/kubevirt\.io:operator/kubevirt-io-operator/g' "$(MANIFESTS_DIR)/combined-manifests.yaml"

# Generate Helm chart
.PHONY: generate-chart
generate-chart: helmify download-manifests
	@echo "Generating Helm chart..."
	@cat "$(MANIFESTS_DIR)/combined-manifests.yaml" | $(HELMIFY) "$(CHART_NAME)"
	@cat default/extra-Chart.yaml > "$(CHART_NAME)/Chart.yaml"
	@echo "Helm chart generated in $(CHART_NAME) directory for KubeVirt version $(KUBEVIRT_VERSION)"

# Default target
.PHONY: all
all: generate-chart

# Clean up
.PHONY: clean
clean:
	rm -rf $(LOCALBIN) $(CHART_NAME) $(MANIFESTS_DIR)

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all              : Generate the Helm chart (default)"
	@echo "  helmify          : Download helmify"
	@echo "  download-manifests : Download KubeVirt manifests"
	@echo "  generate-chart   : Generate the Helm chart"
	@echo "  clean            : Remove generated files and directories"
	@echo "  help             : Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  KUBEVIRT_VERSION : KubeVirt version to use (default: latest stable version)"
	@echo "  CHART_NAME       : Name of the generated chart directory (default: $(CHART_NAME))"
	@echo "  MANIFESTS_DIR    : Directory for storing manifests (default: $(MANIFESTS_DIR))"