package helm

type ChartSearchRequest struct {
	Camr          string `json:"camr"`
	Project       string `json:"project"`
	ComponentName string `json:"componentName"`
	DataCenter    string `json:"dataCenter"`
	Domain        string `json:"domain"`
	EnvName       string `json:"envName"`
	EnvType       string `json:"envType"`
	Network       string `json:"network"`
	Zone          string `json:"zone"`
	ResourceKey   string `json:"resourceKey"`
}
