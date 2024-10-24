package config

import (
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

const defaultConfigPath = "config.yaml"

const defaultENVPrefix = "FSH_"

func InitConfig(path string) {
	rawConfig := loadConfig(path)
	validatedConfig := validateConfig(rawConfig)
	configInstance = &validatedConfig
}

func GetConfig() *FairShareConfig {
	if configInstance == nil {
		InitConfig(defaultConfigPath)
	}
	return configInstance
}

func loadConfig(path string) fairShareRawConfig {

	viper.AutomaticEnv()
	viper.BindEnv("HTTP.Host", defaultENVPrefix+"HTTP_HOST")
	viper.BindEnv("HTTP.Port", defaultENVPrefix+"HTTP_PORT")
	viper.SetConfigFile(path)
	err := viper.ReadInConfig()
	if err != nil {
		panic(errh.PrependErr("failed to read config file "+path, err))
	}
	confInstance := fairShareRawConfig{}
	err = viper.Unmarshal(&confInstance)
	if err != nil {
		panic(errh.PrependErr("failed to unmarshal config file "+path, err))
	}
	return confInstance
}
