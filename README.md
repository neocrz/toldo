# Toldo

A simple lua todo (task) manager

`toldo -h`

```console
Usage: toldo [-h] <command> ...

Todo list with lua.

Options:
   -h, --help            Show this help message and exit.

Commands:
   rm                    Remove a task.
   list                  List all tasks.
   check                 Check a task.
   edit                  Edit a task.
   add                   Add a new task.
```

## Status

- [ ] Tasks
  - [x] task content
  - [ ] change task priority level
  - [x] Add task
  - [x] List task
  - [x] Remove task
  - [x] Check task
- [x] Categories
- [x] Add categories
- [x] List categories
- [x] Default category

Using [flatdb](https://github.com/uleelx/FlatDB) by [uleelx](https://github.com/uleelx) to store todos.
Using [Classic](https://github.com/rxi/classic) by [rxi](https://github.com/rxi) to OOP on the Category Manager.
