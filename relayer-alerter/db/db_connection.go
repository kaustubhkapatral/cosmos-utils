package db

import (
	"log"
	"time"

	"gopkg.in/mgo.v2"

	"github.com/vitwit/cosmos-utils/relayer-alerter/config"
)

var MongoSession *mgo.Session
var err error

func InitDB(cfg *config.Config) {

	MongoDbUrl := &mgo.DialInfo{
		Addrs:    []string{string("localhost")},
		Timeout:  30 * time.Second,
		Username: cfg.MongoDB.Username,
		Password: cfg.MongoDB.Password,
		Database: cfg.MongoDB.Database,
	}

	MongoSession, err = mgo.DialWithInfo(MongoDbUrl)

	if err != nil {
		log.Fatalf("Error while connecting to database : %v", err)
	}

	if err = MongoSession.Ping(); err != nil {
		defer MongoSession.Close()
		log.Fatalf("Error while connecting to Database : %v", err)
	}
	// defer MongoSession.Close()
	log.Println("Database connected successfully!")
}
