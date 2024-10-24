package cmd

import (
	"github.com/guillheu/FairShare/src/ingest/config"
	"github.com/spf13/cobra"
)

const defaultConfigPath string = "config.yaml"

var RootCmd = &cobra.Command{
	Use:   "fairshare",
	Short: "FairShare is a web application to fairly spread users accross activities with limited seats",
	Run: func(cmd *cobra.Command, args []string) {
		config.InitInstance()
		cmd.Usage()
	},
}

func Init() {
	configPath := *RootCmd.PersistentFlags().StringP("config", "c", defaultConfigPath, "path to config.yaml file")

	initRun()
	if configPath == "" {
		configPath = defaultConfigPath
	}
	config.LoadConfigFile(configPath)

	RootCmd.AddCommand(runCmd)
}

func Execute() {
	Init()
	RootCmd.Execute()
}
