# docker-buddy.nvim
A small plugin that allows you to easily restart, ddpause, unpause, and connect to your running docker containers.

This was made mostly for fun and to learn how nvim plugins are built.



# Installation
> Make sure you have `toggleterm.nvim` installed: https://github.com/akinsho/toggleterm.nvim

lazyvim
```lua
{
  'JesseBarron/docker-buddy.nvim',
  config = function () require'docker-buddy' end,
}
```

# Usage
By default, the tool can be opened using `<leader> o` or by running `:DockerBuddy`.

Once the tool is opened, move your cursor over a container you want to interact with and use the following keymaps
to execute actions:
```
R -> Restart container 
P -> Pause container
U -> Unpause container
E -> execute -it bash and connect to the container
```


