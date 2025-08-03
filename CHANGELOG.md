# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Resource map documentation in README
- Comprehensive Terraform tests (`tests/basic.tftest.hcl`)
- Terragrunt configuration example (`terragrunt.hcl.example`)
- Enhanced variable validation with cross-variable checks
- Improved output descriptions with conditional behavior notes
- Security scanning with tfsec integration
- Enhanced domain name validation

### Changed
- Updated Terraform version requirement to `~> 1.13.0`
- Updated AWS provider version requirement to `~> 6.2.0`
- Enhanced variable descriptions with validation requirements
- Improved error messages for better user experience
- Updated Makefile with modern testing and security scanning

### Fixed
- Enhanced validation for health check regions
- Improved domain name format validation
- Better cross-variable validation for hosted zone configuration

## [1.0.0] - 2024-01-01

### Added
- Initial release of DNS Health Check module
- Route 53 health checks with failover capabilities
- CloudWatch alarm integration
- SNS notification support
- Multiple routing policy support
- Comprehensive variable validation
- Basic examples and documentation

### Features
- HTTP/HTTPS/TCP health checks
- Automatic failover routing
- Multi-region health monitoring
- Customizable alarm thresholds
- Email notifications via SNS
- Support for existing and new hosted zones
- Extensive tagging support 