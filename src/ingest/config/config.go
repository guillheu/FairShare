package config

import (
	"encoding/hex"
	"fmt"

	"github.com/guillheu/FairShare/src/util/errh"
	"github.com/spf13/viper"
)

type fairShareRawConfig struct {
	Message string
	HTTP    struct {
		Host string
		Port int
	}
	Activities struct {
		MaxSelection int
		MinSelection int
	}
	AdminAccounts []RawAdminAccount
}

type RawAdminAccount struct {
	Name   string
	PWHash string
	Salt   string
}

type FairShareConfig struct {
	Message string
	HTTP    struct {
		Host string
		Port int
	}
	Activities struct {
		MaxSelection int
		MinSelection int
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

	viper.SetEnvPrefix(defaultENVPrefix)
	viper.AutomaticEnv()
	viper.SetConfigFile(path)
	err := viper.ReadInConfig()
	if err != nil {
		panic(errh.PrependErr("failed to read config file "+path, err))
	}
	// viper.Debug()
	confInstance := fairShareRawConfig{}
	err = viper.Unmarshal(&confInstance)
	if err != nil {
		panic(errh.PrependErr("failed to unmarshal config file "+path, err))
	}
	return confInstance
}

func validateConfig(rawConfig fairShareRawConfig) FairShareConfig {
	var validatedAdminAccounts []AdminAccount
	for index, adminAccount := range rawConfig.AdminAccounts {
		validatedAdminAccount, err := validateAdminAccount(adminAccount)
		if err != nil {
			panic(errh.PrependErr(fmt.Sprintf("failed to validate account #%d "+adminAccount.Name, index), err))
		}
		validatedAdminAccounts = append(validatedAdminAccounts, *validatedAdminAccount)
	}
	return FairShareConfig{
		Message:       rawConfig.Message,
		HTTP:          rawConfig.HTTP,
		Activities:    rawConfig.Activities,
		AdminAccounts: validatedAdminAccounts,
	}
}

func validateAdminAccount(adminAccount RawAdminAccount) (*AdminAccount, error) {
	pwHash, err := hex.DecodeString(adminAccount.PWHash)
	if err != nil {
		return nil, errh.PrependErr("failed to decode password hash hex string", err)
	}
	salt, err := hex.DecodeString(adminAccount.PWHash)
	if err != nil {
		return nil, errh.PrependErr("failed to decode salt hex string", err)
	}
	validatedAdminAccount := AdminAccount{adminAccount.Name, pwHash, salt}
	return &validatedAdminAccount, nil
}
