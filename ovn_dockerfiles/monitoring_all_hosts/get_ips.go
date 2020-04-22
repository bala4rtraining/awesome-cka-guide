package main

import (
	"os"
	"io/ioutil"
	//"fmt"
	"regexp"
	//"strconv"
	"path/filepath"
	//"strings"
    "log"
	)

func check(e error) {
    if e != nil {
        panic(e)
    }
}



//func main(r []string, searchDir []string) {
func main() {
	match := regexp.MustCompile("int-epic([0-9]+)/dc([0-9]+)/hosts")
	searchDir := os.Getenv("HOME") + "/ovn_infrastructure/inventories"

    fileList := []string{}
    err := filepath.Walk(searchDir, func(path string, f os.FileInfo, err error) error {
        fileList = append(fileList, path)
        return nil
    })

    _ = err


    //fmt.Println("all_hosts_ips.yml created")

    //var ret = make([]string, 1)
    f, err := os.OpenFile("all_hosts_ips.yml", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        log.Fatal(err)
    }
    if _, err := f.Write([]byte("all_hosts_ips: \n")); err != nil {
                    log.Fatal(err)
                }


    for _, file := range fileList {

    	if match.MatchString(file) {
    		//fmt.Println(strconv.Itoa(i) + ": " + file)

    		data, err := ioutil.ReadFile(file)
    		check(err)


    		ip := regexp.MustCompile("([0-9]+).([0-9]+).([0-9]+).([0-9]+)")


    		ips := ip.FindAllString(string(data), -1)

   			//ret := strings.Trim(ips, "[")
   			//ret = strings.Trim(ret, "]")

    		//fmt.Println(file + ": ")

    		for _, elem := range ips {
                if _, err := f.Write([]byte("  - ")); err != nil {
                    log.Fatal(err)
                }
                if _, err := f.Write([]byte(elem)); err != nil {
                    log.Fatal(err)
                }
                if _, err := f.Write([]byte("\n")); err != nil {
                    log.Fatal(err)
                }
                //ret = append(ret, elem)
                //ret = append(ret, ",")
    			//fmt.Println(elem, ",")
    		}

    		//fmt.Println(ips)
    	}
    }
    if err := f.Close(); err != nil {
        log.Fatal(err)
    }
}