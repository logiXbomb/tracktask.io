package main

import "testing"

func Test_TaskList(t *testing.T) {
	t.Run("initialize empty task list", func(t *testing.T) {
		tl := TaskList{}

		if len(tl) > 0 {
			t.Fail()
		}
	})

	t.Run("add task", func(t *testing.T) {
		tl := TaskList{}

		newTask := Task{
			title: "",
		}

		tl.Add(newTask)

		if len(tl) != 1 {
			t.Fail()
		}
	})
}
