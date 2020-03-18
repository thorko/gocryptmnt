package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"

	"github.com/hashicorp/vault/api"
	"gopkg.in/alecthomas/kingpin.v2"
)

var v = "1.0.6"

func main() {
	var path = kingpin.Flag("path", "path to mount, envar MOUNT_SRCPATH").Envar("MOUNT_SRCPATH").Short('p').String()
	var target = kingpin.Flag("target", "target path, envar MOUNT_TRGPATH").Envar("MOUNT_TRGPATH").Short('t').String()
	var vault = kingpin.Flag("vault", "vault address, envar VAULT_URL").Envar("VAULT_URL").Short('u').String()
	var token = kingpin.Flag("token", "token for vault, envar VAULT_TOKEN").Short('s').Envar("VAULT_TOKEN").String()
	var secret = kingpin.Flag("secret", "secret path to your secret to get from vault, envar VAULT_SECRET").Short('l').Envar("VAULT_SECRET").String()
	var field = kingpin.Flag("field", "which key contains the password, envar VAULT_KEY").Short('f').Envar("VAULT_KEY").String()
	var interval = kingpin.Flag("interval", "interval of inactivity to unmount, envar IDLE_TIME").Envar("IDLE_TIME").Short('i').Default("300s").String()
	kingpin.Version(v)
	kingpin.Parse()

	config := &api.Config{
		Address: *vault,
	}
	vlclient, err := api.NewClient(config)
	if err != nil {
		log.Fatal(err)
		return
	}
	// connect and authenticate
	vlclient.SetToken(*token)
	vl := vlclient.Logical()

	// get secrets data
	x, err := vl.Read(*secret)
	if err != nil {
		log.Fatal(err)
		return
	}

	l, _ := x.Data["data"].(map[string]interface{})
	passphrase := l[*field]

	err = ioutil.WriteFile("/tmp/passphrase", []byte(passphrase.(string)), 0600)
	if err != nil {
		fmt.Printf("ERROR: coudn't write passphrase file\n")
		os.Exit(1)
	}

	if _, err = os.Stat(*target); os.IsNotExist(err) {
		err = os.Mkdir(*target, 0755)
		if err != nil {
			log.Fatal(err)
		}
	}

	_, err = exec.Command("/usr/bin/gocryptfs", "-passfile", "/tmp/passphrase", "-i", *interval, *path, *target).Output()
	if err != nil {
		log.Fatal(err)
	}

	defer os.Remove("/tmp/passphrase")

}
