package helm_client

import (
	"com.visa.container/vks-client/client"
	"com.visa.container/vks-client/client/helm"
	"fmt"
	"log"
)

func GetHistory() {
	//10.207.89.53:35058
	clientset, err := client.Get("localhost:8443", "72lZ56WLsxFQMfkmYID6NB15I0WmHJspFQtvRd33xro=",
		"examples/resources/certs/client-cert.pem", "examples/resources/certs/client-key.pem", true,
		"")
	if err != nil {
		log.Fatal("unable to create clientset: ", err)
	}
	requestBody := helm.ChartSearchRequest{
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
	}
	fmt.Println(clientset.VksHelmClientSet().History(requestBody))
}
