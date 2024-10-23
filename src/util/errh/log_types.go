package errh

import (
	"errors"
	"strings"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func logLevelFromString(level string) (zerolog.Level, error) {
	switch strings.ToUpper(level) {
	case "DEBUG":
		return zerolog.DebugLevel, nil
	case "INFO":
		return zerolog.InfoLevel, nil
	case "WARN":
		return zerolog.WarnLevel, nil
	case "ERROR":
		return zerolog.ErrorLevel, nil
	case "FATAL":
		return zerolog.FatalLevel, nil
	case "NONE":
		return zerolog.Disabled, nil
	default:
		return -1, errors.New("invalid log level")
	}
}

func InitLogger(logLevelString string) {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	logLevel, err := logLevelFromString(logLevelString)
	if err != nil {
		panic(err)
	}
	zerolog.SetGlobalLevel(logLevel)
}

func Debug(msg string, args ...interface{}) {
	log.Debug().Msgf(msg, args...)
}

func Info(msg string, args ...interface{}) {
	log.Info().Msgf(msg, args...)
}

func Warn(msg string, args ...interface{}) {
	log.Warn().Msgf(msg, args...)
}

func Error(msg string, args ...interface{}) {
	log.Error().Msgf(msg, args...)
}

func Fatal(msg string, args ...interface{}) {
	log.Fatal().Msgf(msg, args...)
}

func DebugErr(err error) {
	log.Debug().Err(err).Send()
}

func InfoErr(err error) {
	log.Info().Err(err).Send()
}

func WarnErr(err error) {
	log.Warn().Err(err).Send()
}

func ErrorErr(err error) {
	log.Error().Err(err).Send()
}

func FatalErr(err error) {
	log.Fatal().Err(err).Send()
}
