package client

import "net/http"

type customHeaderRT struct {
	headers map[string][]string
	rt http.RoundTripper
}

func (h *customHeaderRT) RoundTrip(req *http.Request) (*http.Response, error) {
	for k, vv := range h.headers {
		for _, v := range vv {
			req.Header.Add(k, v)
		}
	}
	return h.rt.RoundTrip(req)
}
