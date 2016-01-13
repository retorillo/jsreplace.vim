# jsreplace.vim

![preview](preview.jpg)

Allows you to use Javascript RegExp pattern replacement

## Usage

```vimL
:%JsReplace pattern [replacement] [flags]
```

flags is a second argument of RegExp constructor
Default value is "gm". See [Options](#Options)

## Dependencies

- [Node.js](https://nodejs.org/)

## Install

### Pathogen (Linux)

```vimL
git clone https://github.com/retorillo/jsreplace.vim.git ~/.vim/bundle/jsreplace.vim
```

### Pathogen (Windows/PowerShell)

```vimL
git clone https://github.com/retorillo/jsreplace.vim.git $home/vimfiles/bundle/jsreplace.vim
```

## Options

When `flags` is not specified, `g:jsreplace_defaultflags` is used for RegExp constructor. 

```vimL
let g:jsreplace_defaultflags = "gm"
```

## License

Copyright (C) Retorillo

Distributed under the the MIT license
