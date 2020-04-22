package helm

import (
	"bytes"
	"com.visa.container/vks-client/client/common"
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
)

type Response struct {
	Body       string
	Header     http.Header
	StatusCode int
}

type Clientset struct {
	params *common.ConnectionParams
}

var client *http.Client

var helmLocalChartAPIPath = "/tpg/%s/camr/%s/project/%s/release-name/%s"

func initClient(clientset *Clientset) error {
	cert, err := tls.LoadX509KeyPair(clientset.params.ClientCertPath, clientset.params.ClientKeyPath)
	if err != nil {
		return err
	}
	transport := &http.Transport{
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: clientset.params.Insecure,
			Certificates:       []tls.Certificate{cert}},
	}
	if !clientset.params.Insecure {
		caCert, err := ioutil.ReadFile(clientset.params.ServerCertPath)
		if err != nil {
			return err
		}
		caCertPool := x509.NewCertPool()
		caCertPool.AppendCertsFromPEM(caCert)
		transport.TLSClientConfig.RootCAs = caCertPool
	}
	client = &http.Client{Transport: transport}
	return nil
}

// This method will be depricated in future
func (clientSet *Clientset) Create(requestBody ChartRequest) (*Response, error) {
	body, err := json.Marshal(requestBody)
	if err != nil {
		return nil, err
	}
	return execute(clientSet.params.ClusterUrl, clientSet.params.ApiKey, http.MethodPost, body, Applicationjson, "")
}

func (clientSet *Clientset) Install(requestBody ChartRequest) (*Response, error) {
	body, err := json.Marshal(requestBody)
	if err != nil {
		return nil, err
	}
	return execute(clientSet.params.ClusterUrl, clientSet.params.ApiKey, http.MethodPost, body, Applicationjson, "")
}

func (clientSet *Clientset) InstallLocalChart(filepath string, tpg string, camr string, project string, releaseName string) (*Response, error) {

	contents, contentType, err := getMultipartFileContents(filepath)
	if err != nil {
		return nil, err
	}
	url := fmt.Sprintf(helmLocalChartAPIPath, tpg, camr, project, releaseName)
	return execute(clientSet.params.ClusterUrl, clientSet.params.ApiKey, http.MethodPost, contents.Bytes(), contentType, url)
}

func (clientSet *Clientset) Update(requestBody ChartRequest) (*Response, error) {
	body, err := json.Marshal(requestBody)
	if err != nil {
		return nil, err
	}
	return execute(clientSet.params.ClusterUrl, clientSet.params.ApiKey, http.MethodPut, body, Applicationjson, "")
}

func (clientSet *Clientset) UpdateLocalChart(filepath string, tpg string, camr string, project string, releaseName string) (*Response, error) {
	contents, contentType, err := getMultipartFileContents(filepath)
	if err != nil {
		return nil, err
	}
	url := fmt.Sprintf(helmLocalChartAPIPath, tpg, camr, project, releaseName)
	return execute(clientSet.params.ClusterUrl, clientSet.params.ApiKey, http.MethodPut, contents.Bytes(), contentType, url)
}

func (clientSet *Clientset) Delete(id string) (*Response, error) {
	return execute(clientSet.params.ClusterUrl, clientSet.params.ApiKey, http.MethodDelete, nil, Applicationjson, id)
}

func (clientSet *Clientset) Lint(url string) (*Response, error) {
	return execute(clientSet.params.ClusterUrl, clientSet.params.ApiKey, http.MethodGet, nil, Applicationjson, "/issues?chart-url="+url)
}

func (clientSet *Clientset) History(requestBody ChartSearchRequest) (*Response, error) {
	body, err := json.Marshal(requestBody)
	if err != nil {
		return nil, err
	}
	return execute(clientSet.params.ClusterUrl, clientSet.params.ApiKey, http.MethodPost, body, Applicationjson, "/_search")
}

func (clientSet *Clientset) Rollback(requestBody ChartRollbackRequest) (*Response, error) {
	body, err := json.Marshal(requestBody)
	if err != nil {
		return nil, err
	}
	return execute(clientSet.params.ClusterUrl, clientSet.params.ApiKey, http.MethodPut, body, Applicationjson, "")
}

func execute(clusterUrl string, apiKey string, method string, body []byte, contentType string, url string) (*Response, error) {
	req, err := http.NewRequest(method,
		"https://"+clusterUrl+"/vks/templates/helm"+url,
		bytes.NewBuffer(body))

	if err != nil {
		return nil, err
	}

	req.Header.Set(Contenttype, contentType)
	req.Header.Set(ApiKeyHeader, apiKey)
	res, err := client.Do(req)
	if err != nil {
		return nil, err
	} else {
		body, err := ioutil.ReadAll(res.Body)
		if err != nil {
			return nil, err
		} else {
			resp := Response{string(body), res.Header, res.StatusCode}
			return &resp, nil
		}
	}
}

func GetClient(params common.ConnectionParams) (*Clientset, error) {
	client := Clientset{params: &params}
	err := initClient(&client)
	return &client, err
}

func getMultipartFileContents(path string) (*bytes.Buffer, string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, "", err
	}
	defer file.Close()
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)
	part, err := writer.CreateFormFile("request", filepath.Base(path))
	if err != nil {
		return nil, "", err
	}
	_, err = io.Copy(part, file)

	err = writer.Close()
	if err != nil {
		return nil, "", err
	}
	return body, writer.FormDataContentType(), nil
}
