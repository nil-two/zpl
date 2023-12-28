zpl
===

[![CI](https://github.com/nil-two/zpl/actions/workflows/test.yml/badge.svg)](https://github.com/nil-two/zpl/actions/workflows/test.yml)

Zip lines by the line number.

```
$ cat <(printf "%s\n" A B C) <(seq 3)
A
B
C
1
2
3
$ zpl <(printf "%s\n" A B C) <(seq 3)
A
1
B
2
C
3

$ cat <(printf "%s\n" X Y Z - 10 20 30)
X
Y
Z
-
10
20
30
$ zpl -s- <(printf "%s\n" X Y Z - 10 20 30)
X
10
Y
20
Z
30
```

Usage
-----

```
$ zpl [<option(s)>] [<file(s)>]
zip lines by the line number.

options:
  -s, --separator=SEP  separate lines by SEP in addition to files
      --help           print usage and exit
```

Requirements
------------

- Perl (5.8.0 or later)

Installation
------------

1. Copy `zpl` into your `$PATH`.
2. Make `zpl` executable.

### Example

```
$ curl -L https://raw.githubusercontent.com/nil-two/zpl/master/zpl > ~/bin/zpl
$ chmod +x ~/bin/zpl
```

Note: In this example, `$HOME/bin` must be included in `$PATH`.

Options
-------

### -s, --separator=SEP

Separate lines by SEP in addition to files.
There is no default value, and it does not split within a file by default.

```
$ zpl -s- <(printf "%s\n" A B - 1 2)
A
1
B
2

$ zpl -s--- <(printf "%s\n" A B --- 1 2 3 --- X)
A
1
X
B
2

3


```

### --help

Print usage and exit.

```
$ zpl --help
(Print usage)
```

License
-------

MIT License

Author
------

nil2 <nil2@nil2.org>
