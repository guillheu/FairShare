package cmd

import (
	"fmt"

	"github.com/guillheu/FairShare/src/ingest/config"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var runCmd = &cobra.Command{
	Use:   "run",
	Short: "Run the FairShare server",
	Run: func(cmd *cobra.Command, args []string) {
		config.InitInstance()
		fmt.Println(cmd.Flags().Lookup("host").Value)
		fmt.Println(config.GetConfig())
	},
}

const defaultHost string = "0.0.0.0"
const defaultPort int = 8025

func initRun() {

	runCmd.Flags().String("host", defaultHost, "local ip address to bind the HTTP server to")
	runCmd.Flags().Int("port", defaultPort, "port for the HTTP server to listen on")
	viper.BindPFlag("HTTP.Host", runCmd.Flags().Lookup("host"))
	viper.BindPFlag("HTTP.Port", runCmd.Flags().Lookup("port"))
}
