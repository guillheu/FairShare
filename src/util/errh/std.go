package errh

import (
	"fmt"
	"os"
)

func PrintErrln(input string) {
	fmt.Fprintln(os.Stderr, input)
}
