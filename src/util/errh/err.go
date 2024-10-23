package errh

import "fmt"

func CheckFatalErr(err error) {
	if err != nil {
		FatalErr(err)
		panic(err)
	}
}

func CheckErrorErr(err error) bool {
	if err != nil {
		ErrorErr(err)
		return true
	}
	return false
}

func CheckWarnErr(err error) bool {
	if err != nil {
		WarnErr(err)
		return true
	}
	return false
}

func CheckInfoErr(err error) bool {
	if err != nil {
		InfoErr(err)
		return true
	}
	return false
}

func CheckDebugErr(err error) bool {
	if err != nil {
		DebugErr(err)
		return true
	}
	return false
}

func PrependErr(msg string, err error) error {
	if err == nil {
		return nil
	}
	return fmt.Errorf(msg+": %v", err)
}
