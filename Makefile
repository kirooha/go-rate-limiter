INGRESS_HOST:=$(shell kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
INGRESS_PORT:=$(shell kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
GATEWAY_URL:=$(INGRESS_HOST):$(INGRESS_PORT)

docker:
	docker build --rm -t go-app:v1 .

config:
	kubectl apply -f config.yaml
rate-limiter:
	kubectl apply -f rate-limit-service.yaml
gateway:
	kubectl apply -f gateway.yaml
envoy-global:
	kubectl apply -f envoy.global.yaml
envoy-local:
	kubectl apply -f envoy.local.yaml
deployment:
	kubectl apply -f deployment.yaml
service:
	kubectl apply -f service.yaml
eval:
	eval $(minikube docker-env)

kube-go: eval docker gateway deployment service
kube-local: eval docker gateway envoy-local deployment service
kube-global: eval docker config rate-limiter gateway envoy-global deployment service

cleanup-go:
	kubectl delete -f gateway.yaml
	kubectl delete -f deployment.yaml
	kubectl delete -f service.yaml

cleanup-local:
	kubectl delete -f gateway.yaml
	kubectl delete -f envoy.local.yaml
	kubectl delete -f deployment.yaml
	kubectl delete -f service.yaml

cleanup-global:
	kubectl delete -f config.yaml
	kubectl delete -f rate-limit-service.yaml
	kubectl delete -f gateway.yaml
	kubectl delete -f envoy.global.yaml
	kubectl delete -f deployment.yaml
	kubectl delete -f service.yaml

test-bar:
	curl -v http://$(GATEWAY_URL)/bar
test-foo:
	curl -v \
		--header 'Content-Type: application/json' \
		--data '{"name":"Sherlock", "address":"221B Baker Street"}' \
		 http://$(GATEWAY_URL)/foo
test-foo-big:
	rm -f foo-big.txt
	truncate -s 5000M foo-big.txt
	curl -v \
		--request POST \
		--header 'Content-Type: application/json' \
		--upload-file foo-big.txt \
		 http://$(GATEWAY_URL)/foo

gateway-url:
	echo $(GATEWAY_URL)
