// package helm_client
package main

import (
	"com.visa.container/vks-client/client"
	"fmt"
	"log"
)

// func InstallLocalChart() {
func main() {
	//10.207.89.53:35058
	clientset, err := client.Get("https://10.207.89.53:35058", "72lZ56WLsxFQMfkmYID6NB15I0WmHJspFQtvRd33xro=",
		"/root/workspace/CV_SDK/com.visa.container/vks-client@v0.2.1/examples/resources/certs/np-cls2/vksclient-cert.pem", "/root/workspace/CV_SDK/com.visa.container/vks-client@v0.2.1/examples/resources/certs/np-cls2/vksclient-key.pem", true,
		"")
	if err != nil {
		log.Fatal("unable to create clientset: ", err)
	}
	/*fmt.Println(clientset.VksHelmClientSet().InstallLocalChart("/Users/pasahu/Downloads/local-chart-0.1.0.tgz",
		"VCPT",
		"0018916",
		"TEST",
		"local"))*/

	fmt.Println(clientset.VksHelmClientSet().InstallLocalChart("https://artifactory.trusted.visa.com:443/vks-templates-np/VCPT-0018916-CVVKDDEV/local-chart-0.1.0.tgz",
		"VCPT",
		"0018916",
		"TEST",
		"local"))
}


