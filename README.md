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

## Dependencies

They are already included under the `dep` folder. No need to install.

- [flatdb](https://github.com/uleelx/FlatDB) to store tasks.
- [Classic](https://github.com/rxi/classic) to make the Category Manager and Category classes.
- [argparse](https://github.com/luarocks/argparse/tree/master) to handle inputs.

## Status

- [ ] Tasks
  - [x] task content
  - [ ] change task priority level
  - [x] Add task
  - [x] List task
  - [x] Remove task
  - [x] Check task
- [ ] Categories
  - [x] Add categories
  - [x] List categories
  - [x] Default category
