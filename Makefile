HUB_VALUES ?= hub-clusters/day2/hub-env-values/dev/east/dev-hub-east-1/values.yaml

.PHONY: validate
validate:
	HUB_VALUES="$(CURDIR)/$(HUB_VALUES)" $(CURDIR)/scripts/validate.sh
