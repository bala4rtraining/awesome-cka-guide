// package helm_client
package main

import (
	"com.visa.container/vks-client/client"
	"fmt"
	"log"
)

// func Lint() {
func main() {
//	clientset, err := client.Get("localhost:8443", "72lZ56WLsxFQMfkmYID6NB15I0WmHJspFQtvRd33xro=",
//		"examples/resources/certs/client-cert.pem", "examples/resources/certs/client-key.pem", true,
//		"")
       clientset, err := client.Get("10.207.89.53:35058", "/BCKnUCeSG8sOrqltPJr3LNmw0QJgIQYWqLLVS4HStE=",
                "/root/workspace/CV_SDK/com.visa.container/vks-client@v0.2.1/examples/resources/certs/np-cls2/vksclient-cert.pem",
                "/root/workspace/CV_SDK/com.visa.container/vks-client@v0.2.1/examples/resources/certs/np-cls2/vksclient-key.pem", true,
                "")
	if err != nil {
		log.Fatal("unable to create clientset: ", err)
	}
	fmt.Println(clientset.VksHelmClientSet().Lint("https://artifactory.trusted.visa.com/ovn-extra-el7/helm-test-chart-poc.tar.gz"))
}
