
src/requirements.txt: pyproject.toml  poetry.lock
	poetry export -o src/requirements.txt --without-hashes

auth:
	gcloud auth application-default login

deploy: src/requirements.txt
	gcloud app deploy src

tf-init: auth
	terraform -chdir=terraform init

tf-apply: src/requirements.txt
	terraform -chdir=terraform apply

tf-apply-auto: src/requirements.txt
	terraform -chdir=terraform apply -auto-approve  
