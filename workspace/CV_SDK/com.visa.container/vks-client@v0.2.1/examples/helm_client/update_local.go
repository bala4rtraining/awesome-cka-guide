package helm_client

import (
	"com.visa.container/vks-client/client"
	"fmt"
	"log"
)

func UpdateLocalChart() {
	clientset, err := client.Get("localhost:8443", "72lZ56WLsxFQMfkmYID6NB15I0WmHJspFQtvRd33xro=",
		"examples/resources/certs/client-cert.pem", "examples/resources/certs/client-key.pem", true,
		"")
	if err != nil {
		log.Fatal("unable to create clientset: ", err)
	}
	/*fmt.Println(clientset.VksHelmClientSet().UpdateLocalChart("/Users/pasahu/Downloads/local-chart-0.1.0.tgz",
		"VCPT",
		"0018916",
		"TEST",
		"local"))*/

	fmt.Println(clientset.VksHelmClientSet().InstallLocalChart("/Users/pasahu/Downloads/local-chart-0.1.2.tgz",
		"VCPT",
		"0018916",
		"TEST",
		"local"))
}
