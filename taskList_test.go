package main

import "testing"

func Test_TaskList(t *testing.T) {
	t.Run("initialize empty task list", func(t *testing.T) {
		tl := TaskList{}

		if len(tl) > 0 {
			t.Fail()
		}
	})
}
