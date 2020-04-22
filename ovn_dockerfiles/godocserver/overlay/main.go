package main

import (
	"fmt"
	"os/exec"
	"time"
)

func setup(done chan bool) {
	cmd1 := exec.Command("/bin/sh", "-c", "/go/src/visa.com/start.sh")
	cmd1.Start()
	cmd1.Wait()
	fmt.Println("done")
	// Send a value to notify that we're done.
	done <- true
}
func worker(done chan bool) {
	fmt.Print("Pulling repos...")
	cmd2 := exec.Command("/bin/sh", "-c", "/go/src/visa.com/pull.sh")
	cmd2.Start()
	cmd2.Wait()
	fmt.Println("done")
	// Send a value to notify that we're done.
	done <- true
}
func task() {
	done := make(chan bool, 1)
	go worker(done)
	// Block until we receive a notification from the
	// worker on the channel.
	<-done
	cmd3 := exec.Command("/bin/sh", "-c", "$(if pgrep godoc; then pkill -x godoc; fi)")
	cmd3.Run()
	fmt.Println("godoc server Terminated")
	server()
}
func server() {
	cmd4 := exec.Command("/bin/sh", "-c", "godoc -http=:6060 -goroot=/go")
	cmd4.Start()
	fmt.Println("starting Godoc server again at",time.Now().String())
	select {
	case <-time.After(time.Duration(18000) * time.Second):
		fmt.Println("returning the task function")
		return
	}
}
func main() {
	fmt.Println("main started")
	donesetup := make(chan bool, 1)
	go setup(donesetup)
	// Block until we receive a notification from the
	// worker on the channel.
	<-donesetup
	fmt.Println("set up done")
	for {
		task()
	}
}
