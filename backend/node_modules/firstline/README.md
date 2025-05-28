# Firstline

[![Build status](https://img.shields.io/travis/pensierinmusica/firstline.svg)](https://travis-ci.com/pensierinmusica/firstline)
[![Test coverage](https://img.shields.io/coveralls/pensierinmusica/firstline.svg)](https://coveralls.io/r/pensierinmusica/firstline)
[![Dependencies](https://img.shields.io/david/pensierinmusica/firstline.svg)](https://www.npmjs.com/package/firstline)
[![Npm version](https://img.shields.io/npm/v/firstline.svg)](https://www.npmjs.com/package/firstline)
[![License](https://img.shields.io/github/license/pensierinmusica/firstline.svg)](https://www.npmjs.com/package/firstline)

## Introduction

Firstline is a [npm](http://npmjs.org) async module for [NodeJS](http://nodejs.org/), that **reads and returns the first line of any file**. It uses native JS promises and streams (requires Node >= v6.4.0). It is well tested and built for high performance.

It is particularly suited when you need to programmatically access the first line of a large amount of files, while handling errors if they occur.

## Install

`npm install firstline`

## Usage

`firstline(filePath, [lineEnding])`

- filePath (String): the full path to the file you want to read.
- lineEnding (String, optional): the character used for line ending (defaults to `\n`).

Incrementally reads data from `filePath` until it reaches the end of the first line.

Returns a promise, eventually fulfilled with a string.

## Examples

```js
// Imagine the file content is:
// abc
// def
// ghi
//

firstline('./my-file.txt');
// -> Returns a promise that will be fulfilled with 'abc'.

firstline('./my-file.txt', '\r');
// -> Same as above, but using '\r' as line ending.
```

***

MIT License