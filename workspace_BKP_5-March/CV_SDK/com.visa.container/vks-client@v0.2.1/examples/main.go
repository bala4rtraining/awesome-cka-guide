package main

import (
	"com.visa.container/vks-client/examples/k8_client"
)

func main() {
	k8_client.GetPods()
	//helm_client.InstallLocalChart()
	//helm_client.UpdateLocalChart()
	//helm_client.GetHistory()
	//helm_client.DeleteChart()
	//helm_client.Rollback()
	//helm_client.Lint()
}
