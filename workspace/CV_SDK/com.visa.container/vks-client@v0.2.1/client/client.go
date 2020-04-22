package client

import (
	"com.visa.container/vks-client/client/common"
	"com.visa.container/vks-client/client/helm"
	"com.visa.container/vks-client/client/vks"
	"fmt"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"net/http"
)

func Get(clusterUrl string, apiKey string, clientCertPath string, clientKeyPath string, insecure bool, serverCertPath string) (*vks.Clientset, error) {

	if !insecure && serverCertPath == "" {
		return nil, fmt.Errorf("serverCertPath is required for secure connections")
	}

	if clientCertPath == "" || clientKeyPath == "" {
		return nil, fmt.Errorf("clientCertPath/clientKeyPath is required")
	}

	if clusterUrl == "" {
		return nil, fmt.Errorf("clusterUrl is required")
	}

	if apiKey == "" {
		return nil, fmt.Errorf("apiKey is required")
	}

	params := common.ConnectionParams{
		ClusterUrl:     clusterUrl,
		ApiKey:         apiKey,
		ClientCertPath: clientCertPath,
		ClientKeyPath:  clientKeyPath,
		Insecure:       insecure,
		ServerCertPath: serverCertPath,
	}

	tlsVar := rest.TLSClientConfig{
		Insecure: insecure,
		CertFile: clientCertPath,
		KeyFile:  clientKeyPath,
	}

	if !insecure {
		tlsVar.CAFile = serverCertPath
	}

	config := rest.Config{
		Host:            clusterUrl,
		TLSClientConfig: tlsVar,
	}

	wt := config.WrapTransport
	config.WrapTransport = func(rt http.RoundTripper) http.RoundTripper {
		if wt != nil {
			rt = wt(rt)
		}
		return &customHeaderRT{
			headers: map[string][]string{"X-Api-Key": []string{apiKey}},
			rt:      rt,
		}
	}

	k8sClientset, err := kubernetes.NewForConfig(&config)
	if err != nil {
		return nil, err
	}
	helmClientset, err := helm.GetClient(params)
	if err != nil {
		return nil, err
	}
	return vks.Get(k8sClientset, helmClientset), nil
}
