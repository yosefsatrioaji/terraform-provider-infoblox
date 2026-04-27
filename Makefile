.PHONY: build package clean
TEST?=$$(go list ./... | grep -v 'vendor')
HOSTNAME=hashicorp.com
NAMESPACE=infobloxopen
NAME=infoblox
BINARY=terraform-provider-${NAME}
VERSION=2.13.1
OSNAME=linux
OSARCH=amd64

.EXPORT_ALL_VARIABLES:
  TF_SCHEMA_PANIC_ON_ERROR=1
  GO111MODULE=on
  GOFLAGS=-mod=vendor

default: install

build:
	mkdir -p build
	CGO_ENABLED=0 GOOS=${OSNAME} GOARCH=${OSARCH} go build -o build/${BINARY}_${VERSION} -trimpath -mod=vendor

package: clean build
	mkdir -p package/${VERSION}
	mv build/${BINARY}_${VERSION} package/${VERSION}/${BINARY}_${VERSION}
	cp README.md package/${VERSION}/README.md
	cp LICENSE package/${VERSION}/LICENSE
	chmod -R 777 package/${VERSION}/
	cd package/${VERSION}/ && zip -r terraform-provider-${NAME}_${VERSION}_${OSNAME}_${OSARCH}.zip ${BINARY}_${VERSION} README.md LICENSE
	cd package/${VERSION}/ && shasum -a 256 terraform-provider-${NAME}_${VERSION}_${OSNAME}_${OSARCH}.zip > terraform-provider-${NAME}_${VERSION}_SHA256SUMS

clean:
	rm -rf build
	rm -rf package
	rm -rf terraform.d