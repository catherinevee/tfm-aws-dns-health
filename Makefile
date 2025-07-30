# Makefile for AWS Route 53 Health Checks + Failover Terraform Module

.PHONY: help init plan apply destroy validate fmt lint test clean examples-basic examples-advanced

# Default target
help:
	@echo "AWS Route 53 Health Checks + Failover Terraform Module"
	@echo ""
	@echo "Available targets:"
	@echo "  help              - Show this help message"
	@echo "  init              - Initialize Terraform"
	@echo "  plan              - Plan Terraform changes"
	@echo "  apply             - Apply Terraform changes"
	@echo "  destroy           - Destroy Terraform resources"
	@echo "  validate          - Validate Terraform configuration"
	@echo "  fmt               - Format Terraform code"
	@echo "  lint              - Lint Terraform code with tflint"
	@echo "  test              - Run tests"
	@echo "  clean             - Clean up temporary files"
	@echo "  examples-basic    - Run basic example"
	@echo "  examples-advanced - Run advanced example"
	@echo ""

# Terraform operations
init:
	@echo "Initializing Terraform..."
	terraform init

plan:
	@echo "Planning Terraform changes..."
	terraform plan

apply:
	@echo "Applying Terraform changes..."
	terraform apply

destroy:
	@echo "Destroying Terraform resources..."
	terraform destroy

# Validation and formatting
validate:
	@echo "Validating Terraform configuration..."
	terraform validate

fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive

lint:
	@echo "Linting Terraform code..."
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init; \
		tflint; \
	else \
		echo "tflint not found. Install with: go install github.com/terraform-linters/tflint/cmd/tflint@latest"; \
	fi

# Testing
test: validate fmt lint
	@echo "Running tests..."
	@echo "All validation checks passed!"

# Cleanup
clean:
	@echo "Cleaning up temporary files..."
	rm -rf .terraform
	rm -rf .terraform.lock.hcl
	rm -rf terraform.tfstate*
	rm -rf .tflint.hcl

# Example configurations
examples-basic:
	@echo "Running basic example..."
	cd examples/basic && \
	terraform init && \
	terraform plan

examples-advanced:
	@echo "Running advanced example..."
	cd examples/advanced && \
	terraform init && \
	terraform plan

# Development helpers
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md.tmp && \
		mv README.md.tmp README.md; \
	else \
		echo "terraform-docs not found. Install with: go install github.com/terraform-docs/terraform-docs/cmd/terraform-docs@latest"; \
	fi

security-scan:
	@echo "Running security scan..."
	@if command -v terrascan >/dev/null 2>&1; then \
		terrascan scan -i terraform; \
	else \
		echo "terrascan not found. Install with: go install github.com/tenable/terrascan/cmd/terrascan@latest"; \
	fi

# CI/CD helpers
ci-init:
	@echo "CI: Initializing Terraform..."
	terraform init -backend=false

ci-plan:
	@echo "CI: Planning Terraform changes..."
	terraform plan -detailed-exitcode

ci-validate:
	@echo "CI: Validating Terraform configuration..."
	terraform validate
	terraform fmt -check -recursive

# Environment-specific targets
dev-plan:
	@echo "Planning for development environment..."
	terraform workspace select dev || terraform workspace new dev
	terraform plan -var-file=environments/dev.tfvars

staging-plan:
	@echo "Planning for staging environment..."
	terraform workspace select staging || terraform workspace new staging
	terraform plan -var-file=environments/staging.tfvars

prod-plan:
	@echo "Planning for production environment..."
	terraform workspace select prod || terraform workspace new prod
	terraform plan -var-file=environments/prod.tfvars

# Backup and restore
backup:
	@echo "Backing up Terraform state..."
	@if [ -f terraform.tfstate ]; then \
		cp terraform.tfstate terraform.tfstate.backup.$$(date +%Y%m%d_%H%M%S); \
		echo "State backed up successfully"; \
	else \
		echo "No terraform.tfstate file found"; \
	fi

restore:
	@echo "Restoring Terraform state..."
	@if [ -f terraform.tfstate.backup.* ]; then \
		cp terraform.tfstate.backup.$$(ls terraform.tfstate.backup.* | tail -1) terraform.tfstate; \
		echo "State restored successfully"; \
	else \
		echo "No backup files found"; \
	fi

# Module versioning
version:
	@echo "Current module version:"
	@grep -E 'version.*=.*"[0-9]+\.[0-9]+\.[0-9]+"' versions.tf || echo "No version found in versions.tf"

# Dependencies check
check-deps:
	@echo "Checking dependencies..."
	@echo "Terraform version:"
	terraform version
	@echo ""
	@echo "AWS CLI version:"
	aws --version 2>/dev/null || echo "AWS CLI not found"
	@echo ""
	@echo "Available tools:"
	@command -v tflint >/dev/null 2>&1 && echo "✓ tflint" || echo "✗ tflint"
	@command -v terraform-docs >/dev/null 2>&1 && echo "✓ terraform-docs" || echo "✗ terraform-docs"
	@command -v terrascan >/dev/null 2>&1 && echo "✓ terrascan" || echo "✗ terrascan"

# All-in-one setup
setup: check-deps init validate fmt lint
	@echo "Setup completed successfully!"

# All-in-one teardown
teardown: backup destroy clean
	@echo "Teardown completed successfully!" 