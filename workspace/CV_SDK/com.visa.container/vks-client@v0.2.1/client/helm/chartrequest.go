package helm

type ChartRequest struct {
	ChartUrl    string `json:"chartUrl"`
	ReleaseName string `json:"releaseName"`
}
