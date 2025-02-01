package main

/*
#include <stdlib.h>
*/
import "C"
import (
	"encoding/base64"
	"os"
	"path/filepath"
)

//export FindAndEncodeThumbnail
func FindAndEncodeThumbnail(root *C.char) *C.char {
	var result string
	err := filepath.Walk(C.GoString(root), func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if !info.IsDir() && filepath.Base(path) == "thumbnail.png" {
			data, err:= os.ReadFile(path)
			if err != nil {
				return err
			}

			result = base64.StdEncoding.EncodeToString(data)
			return filepath.SkipAll
		}
		return nil
	})

	if err != nil {
		return nil
	}

	if result == "" {
        return C.CString("")
    }

	return C.CString(result)
}

func main() {}