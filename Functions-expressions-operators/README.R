## ------------------------------------------------------------------------
class(4)
class("foo")
class(TRUE)
class(sin)

## ------------------------------------------------------------------------
class(sin) <- "foo"
class(sin)

## ------------------------------------------------------------------------
sin(0)

## ------------------------------------------------------------------------
foo <- function(x, y, z) UseMethod("foo")

## ------------------------------------------------------------------------
foo(1, 2, 3)

## ------------------------------------------------------------------------
foo.default <- function(x, y, z) {
   cat("default foo\n")
}

## ------------------------------------------------------------------------
foo(1, 2, 3)

## ------------------------------------------------------------------------
foo.numeric <- function(x, y, z) {
   cat("numeric\n")
}

## ------------------------------------------------------------------------
foo(1, 2, 3)

## ------------------------------------------------------------------------
bar <- function(x, y, z) UseMethod("foo", y)

## ------------------------------------------------------------------------
foo("foo",2,3)
bar("foo",2,3)
bar(1,"bar",3)

## ------------------------------------------------------------------------
x <- 1
foo(x, 2, 3)

## ------------------------------------------------------------------------
class(x) <- c("a", "b", "c")
foo(x, 2, 3)

## ------------------------------------------------------------------------
foo.a <- function(x, y, z) cat("a\n")
foo.b <- function(x, y, z) cat("b\n")
foo.c <- function(x, y, z) cat("c\n")
foo(x, 2, 3)

## ------------------------------------------------------------------------
class(x) <- c("b", "a", "c")
foo(x, 2, 3)

class(x) <- c("c", "b", "a")
foo(x, 2, 3)

## ------------------------------------------------------------------------
foo.a <- function(x, y, z) {
  cat("a\n")
  NextMethod()
}
foo.b <- function(x, y, z) {
  cat("b\n")
  NextMethod()
}
foo.c <- function(x, y, z) {
  cat("c\n")
  NextMethod()
}

## ------------------------------------------------------------------------
class(x) <- c("a", "b", "c")
foo(x, 2, 3)

class(x) <- c("b", "a", "c")
foo(x, 2, 3)

class(x) <- c("c", "b", "a")
foo(x, 2, 3)

## ------------------------------------------------------------------------
`+.a` <- function(e1, e2) {
  cat("+.a\n")
  NextMethod()
}
x + 2

## ------------------------------------------------------------------------
x + 3
3 + x

## ------------------------------------------------------------------------
x <- 1 ; y <- 3
class(x) <- "a"
class(y) <- "b"
x + y
y + x

## ------------------------------------------------------------------------
`+.b` <- function(e1, e2) {
  cat("+.b\n")
  NextMethod()
}

x + y
y + x

## ------------------------------------------------------------------------
class(x) <- c("a", "b")
x + 2
x + y

## ------------------------------------------------------------------------
`!.a` <- function(x) {
  cat("Not for a\n")
  NextMethod()
}
!x

## ------------------------------------------------------------------------
`+.a` <- function(e1, e2) {
  if (missing(e2)) {
    cat("Unary\n")
  } else {
    cat("Binary\n")
  }
  NextMethod()
}

class(x) <- "a"
+x
2+x

## ------------------------------------------------------------------------
Ops.c <- function(e1, e2) {
  cat(paste0("Ops.c (", .Generic, ")\n"))
  NextMethod()
}

z <- 2
class(z) <- "c"
z + 1
1 + z
z ^ 3

## ------------------------------------------------------------------------
class(z) <- c("a", "c")
1 + z
2 * z

## ------------------------------------------------------------------------
`%times%` <- function(n, body) {
  body <- substitute(body)
  for (i in 1:n)
    eval(body, parent.frame())
}

## ------------------------------------------------------------------------
4 %times% cat("foo\n")

## ------------------------------------------------------------------------
2 %times% {
  cat("foo\n")
  cat("bar\n")
}

