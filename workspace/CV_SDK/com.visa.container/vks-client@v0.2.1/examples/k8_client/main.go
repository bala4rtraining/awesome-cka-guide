package main

import (
	"com.visa.container/vks-client/client"
	"fmt"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"log"
)

func main() {
	// MA+k5kwALv2k6zswMMLxhvK9zBgDBNA8q3zJKbYTvg4= aagarwa1
	// 72lZ56WLsxFQMfkmYID6NB15I0WmHJspFQtvRd33xro= pasahu
	// B9UZIrjU0dDQ0aSvlrfuUflKaOBvNCwtHePZbSjP1kc= pasahu - NP
//	clientset, err := client.Get("ik8s-np-01.k8s-np-cls1-b.trusted.visa.com:8443", "B9UZIrjU0dDQ0aSvlrfuUflKaOBvNCwtHePZbSjP1kc=",
//		"examples/resources/certs/np-cls2/client-cert.pem", "examples/resources/certs/np-cls2/client-key.pem", true,
//		"")
        clientset, err := client.Get("https://10.207.89.53:35058", "/BCKnUCeSG8sOrqltPJr3LNmw0QJgIQYWqLLVS4HStE=",
		"/root/workspace/CV_SDK/com.visa.container/vks-client@v0.2.1/examples/resources/certs/np-cls2/vksclient-cert.pem", 
		"/root/workspace/CV_SDK/com.visa.container/vks-client@v0.2.1/examples/resources/certs/np-cls2/vksclient-key.pem", true,
		"")
	if err != nil {
		log.Fatal("unable to create clientset: ", err)
	}

	namespace := "0018591-development-business"
	pods, err := clientset.CoreV1().Pods(namespace).List(metav1.ListOptions{Watch: false})
	if err != nil {
		fmt.Print("error occurred: ", err)
	} else {
		fmt.Printf("Number of pods in namespace %s is %d ", namespace, len(pods.Items))
	}
}
