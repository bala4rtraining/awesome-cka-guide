package helm_client

import (
	"com.visa.container/vks-client/client"
	"com.visa.container/vks-client/client/helm"
	"fmt"
	"log"
)

func Rollback() {
	clientset, err := client.Get("localhost:8443", "72lZ56WLsxFQMfkmYID6NB15I0WmHJspFQtvRd33xro=",
		"examples/resources/certs/client-cert.pem", "examples/resources/certs/client-key.pem", true,
		"")
	if err != nil {
		log.Fatal("unable to create clientset: ", err)
	}

	requestBody := helm.ChartRollbackRequest{
		ResourceKey:   "rkey1",
		DataCenter:    "oce",
		Project:       "CVVKDDEV",
		Camr:          "0018916",
		Network:       "container-non-prod-gen",
		Zone:          "business",
		EnvName:       "Development",
		EnvType:       "Development",
		Domain:        "visa.com",
		ComponentName: "test_vks_v1_80",
		ServiceId:     "5e42d96b4db63e3e800ee138",
	}
	fmt.Println(clientset.VksHelmClientSet().Rollback(requestBody))
}
