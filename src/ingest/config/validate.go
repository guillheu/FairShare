package config

import (
	"bytes"
	"encoding/hex"
	"fmt"
	"net"
	"slices"

	"github.com/guillheu/FairShare/src/util/errh"
)

func validateConfig(rawConfig fairShareRawConfig) FairShareConfig {

	err := validateHTTPConfig(rawConfig.HTTP.Host, rawConfig.HTTP.Port)
	if err != nil {
		panic(errh.PrependErr("failed to validate http config", err))
	}

	var validatedAdminAccounts []AdminAccount
	for index, adminAccount := range rawConfig.AdminAccounts {
		validatedAdminAccount, err := validateAdminAccount(adminAccount)
		if err != nil {
			panic(errh.PrependErr(fmt.Sprintf("failed to validate account #%d "+adminAccount.Name, index), err))
		}
		validatedAdminAccounts = append(validatedAdminAccounts, *validatedAdminAccount)
		err = validateAdminAccountsUnique(validatedAdminAccounts)
		if err != nil {
			panic(errh.PrependErr("admin accounts fields arent unique", err))
		}
	}
	return FairShareConfig{
		HTTP:          rawConfig.HTTP,
		AdminAccounts: validatedAdminAccounts,
	}
}

func validateHTTPConfig(host string, port int) error {
	if net.ParseIP(host) == nil {
		return fmt.Errorf("host \"%v\" is not a valid IP address", host)
	}
	if port < 1 || port > 65536 {
		return fmt.Errorf("port number %d is outside the valid port range (between 1 and 65536)", port)
	}
	return nil
}

func validateAdminAccount(adminAccount RawAdminAccount) (*AdminAccount, error) {
	pwHash, err := hex.DecodeString(adminAccount.PWHash)
	if err != nil {
		return nil, errh.PrependErr("failed to decode password hash hex string", err)
	}
	salt, err := hex.DecodeString(adminAccount.Salt)
	if err != nil {
		return nil, errh.PrependErr("failed to decode salt hex string", err)
	}
	validatedAdminAccount := AdminAccount{adminAccount.Name, pwHash, salt}
	return &validatedAdminAccount, nil
}

func validateAdminAccountsUnique(adminAccounts []AdminAccount) error {
	var usedNames []string
	var usedPWHashes [][]byte
	var usedSalts [][]byte
	for index, adminAccount := range adminAccounts {
		if slices.Contains(usedNames, adminAccount.Name) {
			return fmt.Errorf("name #%d \"%v\" used multiple times. Admin names must be unique", index, adminAccount.Name)
		}
		for _, usedPWHash := range usedPWHashes {
			if bytes.Equal(usedPWHash, adminAccount.PWHash) {
				return fmt.Errorf("password hash #%d %v used multipse times. Password hashes must be unique", index, hex.EncodeToString(usedPWHash))
			}
		}
		for _, usedSalt := range usedSalts {
			if bytes.Equal(usedSalt, adminAccount.Salt) {
				return fmt.Errorf("salt #%d %v used multipse times. Salts must be unique", index, hex.EncodeToString(usedSalt))
			}
		}
		usedNames = append(usedNames, adminAccount.Name)
		usedPWHashes = append(usedPWHashes, adminAccount.PWHash)
		usedSalts = append(usedSalts, adminAccount.Salt)
		// fmt.Println(usedSalts)
	}
	return nil
}
