# Variables
LOCALBIN ?= $(shell pwd)/bin
HELMIFY ?= $(LOCALBIN)/helmify
HELM_DOCS ?= $(LOCALBIN)/helm-docs
CHART_NAME ?= kubevirt-chart
MANIFESTS_DIR ?= $(shell pwd)/manifests
PROCESSED_DIR ?= $(shell pwd)/processed

# Get the latest stable KubeVirt version
KUBEVIRT_VERSION ?= $(shell curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)

# Ensure directories exist
$(LOCALBIN) $(MANIFESTS_DIR) $(PROCESSED_DIR):
	mkdir -p $@

# Download helmify
.PHONY: helmify
helmify: $(HELMIFY)
$(HELMIFY): $(LOCALBIN)
	test -s $(LOCALBIN)/helmify || GOBIN=$(LOCALBIN) go install github.com/arttor/helmify/cmd/helmify@latest

# Download helm-docs
.PHONY: helm-docs
helm-docs: $(HELM_DOCS)
$(HELM_DOCS): $(LOCALBIN)
	test -s $(LOCALBIN)/helm-docs || GOBIN=$(LOCALBIN) go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest

# Download and preprocess KubeVirt manifests
.PHONY: prepare-manifests
prepare-manifests: $(MANIFESTS_DIR) $(PROCESSED_DIR)
	@echo "Downloading and preprocessing KubeVirt manifests for version $(KUBEVIRT_VERSION)..."
	@curl -sSL "https://github.com/kubevirt/kubevirt/releases/download/$(KUBEVIRT_VERSION)/kubevirt-operator.yaml" -o "$(MANIFESTS_DIR)/kubevirt-operator.yaml"
	@curl -sSL "https://github.com/kubevirt/kubevirt/releases/download/$(KUBEVIRT_VERSION)/kubevirt-cr.yaml" -o "$(MANIFESTS_DIR)/kubevirt-cr.yaml"
	@cat "$(MANIFESTS_DIR)/kubevirt-operator.yaml" "$(MANIFESTS_DIR)/kubevirt-cr.yaml" > "$(PROCESSED_DIR)/combined-manifests.yaml"
	@sed -i 's/kubevirt\.io:operator/kubevirt-io-operator/g' "$(PROCESSED_DIR)/combined-manifests.yaml"

# Generate Helm chart
.PHONY: generate-chart
generate-chart: helmify prepare-manifests
	@echo "Generating Helm chart..."
	@cat $(PROCESSED_DIR)/*.yaml | $(HELMIFY) "$(CHART_NAME)"
	@cat default/extra-Chart.yaml > "$(CHART_NAME)/Chart.yaml"
	@echo "Helm chart generated in $(CHART_NAME) directory for KubeVirt version $(KUBEVIRT_VERSION)"

# Generate documentation
.PHONY: generate-docs
generate-docs: helm-docs
	@echo "Generating Helm chart documentation..."
	@$(HELM_DOCS) -c $(CHART_NAME)
	@echo "Documentation generated for $(CHART_NAME)"

# Default target
.PHONY: all
all: generate-chart generate-docs

# Clean up
.PHONY: clean
clean:
	rm -rf $(LOCALBIN) $(CHART_NAME) $(MANIFESTS_DIR) $(PROCESSED_DIR)

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all              : Generate the Helm chart and documentation (default)"
	@echo "  helmify          : Download helmify"
	@echo "  helm-docs        : Download helm-docs"
	@echo "  prepare-manifests: Download and preprocess KubeVirt manifests"
	@echo "  generate-chart   : Generate the Helm chart"
	@echo "  generate-docs    : Generate documentation for the Helm chart"
	@echo "  clean            : Remove generated files and directories"
	@echo "  help             : Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  KUBEVIRT_VERSION : KubeVirt version to use (default: latest stable version)"
	@echo "  CHART_NAME       : Name of the generated chart directory (default: $(CHART_NAME))"