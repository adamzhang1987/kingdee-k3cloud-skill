.PHONY: build lint check

build:
	cd kingdee-k3cloud && zip -r ../kingdee-k3cloud.skill .

lint:
	npx --yes markdownlint-cli2 '**/*.md'

check:
	python3 -c "import json, os, re; d=json.load(open('registry.json')); assert os.path.isdir(d['path']), f\"path not found: {d['path']}\"; assert re.match(r'^\d+\.\d+\.\d+$$', d['version']), f\"bad version: {d['version']}\"; print('registry.json OK')"
