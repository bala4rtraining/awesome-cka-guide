package common

type ConnectionParams struct {
	ClusterUrl     string
	ApiKey         string
	ClientCertPath string
	ClientKeyPath  string
	Insecure       bool
	ServerCertPath string
}
