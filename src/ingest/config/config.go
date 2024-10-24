package config

import (
	"fmt"

	"github.com/guillheu/FairShare/src/util/errh"
	"github.com/spf13/viper"
)

type fairShareRawConfig struct {
	HTTP struct {
		Host string
		Port int
	}
	AdminAccounts []RawAdminAccount
}

type RawAdminAccount struct {
	Name   string
	PWHash string
	Salt   string
}

type FairShareConfig struct {
	HTTP struct {
		Host string
		Port int
	}
	AdminAccounts []AdminAccount
}

type AdminAccount struct {
	Name   string
	PWHash []byte
	Salt   []byte
}

var configInstance *FairShareConfig

const defaultENVPrefix = "FSH_"

func GetConfig() *FairShareConfig {
	if configInstance == nil {
		panic(fmt.Errorf("config should first be loaded and validated"))
	}
	return configInstance
}

func LoadConfigFile(path string) {

	viper.AutomaticEnv()
	viper.BindEnv("HTTP.Host", defaultENVPrefix+"HTTP_HOST")
	viper.BindEnv("HTTP.Port", defaultENVPrefix+"HTTP_PORT")
	viper.SetConfigFile(path)
	err := viper.ReadInConfig()
	if err != nil {
		panic(errh.PrependErr("failed to read config file %v"+path, err))
	}
}

func InitInstance() {
	confInstance := fairShareRawConfig{}
	if err := viper.Unmarshal(&confInstance); err != nil {
		panic(errh.PrependErr("failed to unmarshal config ", err))
	}
	validatedConfInstance := validateConfig(confInstance)
	configInstance = &validatedConfInstance
}
