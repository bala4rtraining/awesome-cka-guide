package helm_client

import (
	"com.visa.container/vks-client/client"
	"fmt"
	"log"
)

func Lint() {
	clientset, err := client.Get("localhost:8443", "72lZ56WLsxFQMfkmYID6NB15I0WmHJspFQtvRd33xro=",
		"examples/resources/certs/client-cert.pem", "examples/resources/certs/client-key.pem", true,
		"")
	if err != nil {
		log.Fatal("unable to create clientset: ", err)
	}
	fmt.Println(clientset.VksHelmClientSet().Lint("https://artifactory.trusted.visa.com/helmcharts-snapshots/helm-test-chart-poc/helm-test-chart-poc.tar.gz"))
}
