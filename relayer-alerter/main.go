package main

import (
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/vitwit/cosmos-utils/relayer-alerter/config"
	"github.com/vitwit/cosmos-utils/relayer-alerter/db"
	"github.com/vitwit/cosmos-utils/relayer-alerter/targets"
)

func main() {
	cfg, err := config.ReadConfigFromFile()
	if err != nil {
		log.Fatal(err)
	}

	db.InitDB(cfg)
	defer db.MongoSession.Close()

	var wg sync.WaitGroup
	wg.Add(1)

	// Manage telegram based commands
	go func() {
		for {
			targets.TelegramAlerting(cfg)
			time.Sleep(4 * time.Second)
		}
	}()

	// Calling go routine to send alert about balance changes
	go func() {
		for {
			if err := targets.BalanceChangeAlerts(cfg); err != nil {
				fmt.Println("Error while sending balance change threshold based alerts", err)
			}
			time.Sleep(10 * 60 * time.Second)
		}
	}()

	go func() {
		for {
			if err := targets.DailyBalAlerts(cfg); err != nil {
				fmt.Println("Error while sending daily balance alerts", err)
			}
			time.Sleep(60 * time.Second)
		}
	}()

	go func() {
		for {
			if err := targets.GetEndpointsStatus(cfg); err != nil {
				fmt.Println("Error while sending endpoint status", err)
			}
			time.Sleep(10 * 60 * time.Second)
		}
	}()

	wg.Wait()
}
