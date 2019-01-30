import uuid from 'uuid';
import { Elm } from './Main.elm';

const getItem = key => () => {
	const json = localStorage.getItem(key);
	if (json) {
		try {
			const result = JSON.parse(json);
			return result.map(r => {
				if (!r.status) {
					return {
						...r,
						status: '',
					};
				}
				return r;
			});
		} catch (e) {
			return null;
		}
	}
	return null;
}

const setItem = key => json => {
	localStorage.setItem(key, JSON.stringify(json));
}

const getTasks = getItem('tasks');

const setTasks = setItem('tasks');

const node = document.getElementById('app');

const tl = getTasks() || [];
let activeTask = "";
if (tl && tl.length && tl.length > 0) {
	activeTask = tl[0].id;
}

const app = Elm.Main.init({
	node,
	flags: {
		activeTask,
		tasks: tl,
	},
});

const ports = app.ports;

if (ports && ports.addTask) {
	ports.addTask.subscribe(() => {
		const taskList = getTasks() || [];

		const activeTask = uuid();

		taskList.push({ id: activeTask, title: '' });

		setTasks(taskList);

		if (ports && ports.updateTaskList) {
			ports.updateTaskList.send({
				taskList,
				activeTask,
			});
		}
	});
}

if (ports && ports.saveTaskList) {
	ports.saveTaskList.subscribe(setTasks);
}

if (ports && ports.moveTaskUp) {
	ports.moveTaskUp.subscribe(activeTask => {
		const tl = getTasks();
		
		const index = tl.findIndex(t => t.id === activeTask);
		const newIndex = index - 1;

		const taskList = [];

		for (let i = 0; i < tl.length; i++) {
			if (i === newIndex) {
				taskList.push(tl[index]);
			} else if (i === index) {
				taskList.push(tl[newIndex]);
			} else {
				taskList.push(tl[i]);
			}
		}

		setTasks(taskList);

		if (ports && ports.updateTaskList) {
			ports.updateTaskList.send({
				taskList,
				activeTask,
			});
		}
	});
}

if (ports && ports.moveTaskDown) {
	ports.moveTaskDown.subscribe(activeTask => {
		const tl = getTasks();
		
		const index = tl.findIndex(t => t.id === activeTask);
		const newIndex = index + 1;

		const taskList = [];

		for (let i = 0; i < tl.length; i++) {
			if (i === newIndex) {
				taskList.push(tl[index]);
			} else if (i === index) {
				taskList.push(tl[newIndex]);
			} else {
				taskList.push(tl[i]);
			}
		}

		setTasks(taskList);

		if (ports && ports.updateTaskList) {
			ports.updateTaskList.send({
				taskList,
				activeTask,
			});
		}
	});
}

if (ports && ports.setStatus) {
	ports.setStatus.subscribe(({ activeTask, status }) => {
		let taskList = getTasks();
		taskList = taskList.map(t => {
			if (t.id === activeTask) {
				return { ...t,
					status,
				};
			}
			return t;
		});
		setTasks(taskList);
		ports.updateTaskList.send({
			taskList,
			activeTask,
		})
	});
}

window.addEventListener('beforeinstallprompt', evt => {
	evt.prompt();
});
