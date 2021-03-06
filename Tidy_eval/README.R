## ------------------------------------------------------------------------
library(magrittr)
library(dplyr)
library(tibble)

## ------------------------------------------------------------------------
q <- rlang::quo(2 * x)
q

## ------------------------------------------------------------------------
f <- function(expr) rlang::enquo(expr)
q <- f(2 * x)
q

## ------------------------------------------------------------------------
q[[2]]
environment(q)

## ------------------------------------------------------------------------
rlang::get_expr(q)

## ------------------------------------------------------------------------
rlang::get_env(q)

## ------------------------------------------------------------------------
eval(q)

## ------------------------------------------------------------------------
x <- 1
rlang::eval_tidy(q)
x <- 2
rlang::eval_tidy(q)

## ------------------------------------------------------------------------
f <- function(x, y) rlang::quo(x + y + z)

## ------------------------------------------------------------------------
q <- f(1, 2)
x <- y <- z <- 3
rlang::eval_tidy(q) # 1 + 2 + 3
x + y + z # 3 + 3 + 3

## ------------------------------------------------------------------------
x <- 1:4
y <- 1:4
q <- quo(x+y)
rlang::eval_tidy(q)
rlang::eval_tidy(q, list(x = 5:8))

## ------------------------------------------------------------------------
f <- function(expr,x) {
  q <- rlang::enquo(expr)
  rlang::eval_tidy(q)
}
g <- function(expr,x) {
  q <- rlang::enquo(expr)
  rlang::eval_tidy(q, environment())
}
f(x + y, x = 5:8)
g(x + y, x = 5:8)

## ------------------------------------------------------------------------
rlang::eval_tidy(quote(x + y))

## ------------------------------------------------------------------------
rlang::eval_tidy(quote(xx), env = list2env(list(xx = 5:8)))

## ---- error=TRUE---------------------------------------------------------
rlang::eval_tidy(quo(xx), env = list2env(list(xx = 5:8)))

## ------------------------------------------------------------------------
make_function <- function(args, body) {
  body <- rlang::enquo(body)
  rlang::new_function(args, rlang::get_expr(body), rlang::get_env(body))
}
f <- function(z) make_function(alist(x=, y=), x + y + z)
g <- f(z = 1:4)
g
g(x = 1:4, y = 1:4)

## ------------------------------------------------------------------------
make_function_quo <- function(args, body) {
  body <- rlang::enquo(body)
  rlang::new_function(args, rlang::get_expr(body), rlang::get_env(body))
}
make_function_quote <- function(args, body) {
  body <- substitute(body)
  rlang::new_function(args, body, rlang::caller_env())
}
g <- make_function_quo(alist(x=, y=), x + y)
h <- make_function_quote(alist(x=, y=), x + y)
g(x = 1:4, y = 1:4)
h(x = 1:4, y = 1:4)

## ------------------------------------------------------------------------
cons <- function(elm, lst) list(car=elm, cdr=lst)
lst_length <- function(lst) {
  len <- 0
  while (!is.null(lst)) {
    lst <- lst$cdr
    len <- len + 1
  }
  len
}
lst_to_list <- function(lst) {
  v <- vector(mode = "list", length = lst_length(lst))
  index <- 1
  while (!is.null(lst)) {
    v[[index]] <- lst$car
    lst <- lst$cdr
    index <- index + 1
  }
  v
}

## ------------------------------------------------------------------------
expressions <- function() list(ex = NULL)
add_expression <- function(ex, expr) {
  ex$ex <- cons(rlang::enquo(expr), ex$ex)
  ex
}

## ------------------------------------------------------------------------
make_functions <- function(ex, args) {
  results <- vector("list", length = lst_length(ex$ex))
  i <- 1; lst <- ex$ex
  while (!is.null(lst)) {
    results[[i]] <- 
      rlang::new_function(args, rlang::get_expr(lst$car), 
                           rlang::get_env(lst$car))
    i <- i + 1
    lst <- lst$cdr
  }
  rev(results)
}

## ------------------------------------------------------------------------
make_line_expressions <- function(intercept) {
  expressions() %>% 
    add_expression(coef + intercept) %>%
    add_expression(2*coef + intercept) %>% 
    add_expression(3*coef + intercept) %>% 
    add_expression(4*coef + intercept)
}

## ------------------------------------------------------------------------
eval_line <- function(ex, coef) {
  ex %>% make_functions(alist(coef=)) %>%
    purrr::invoke_map(coef = coef) %>% unlist()
}

## ------------------------------------------------------------------------
make_line_expressions(intercept = 0) %>% eval_line(coef = 1)
make_line_expressions(intercept = 0) %>% eval_line(coef = 2)
make_line_expressions(intercept = 1) %>% eval_line(coef = 1)

## ------------------------------------------------------------------------
add_expression <- function(ex, expr) {
  ex$ex <- cons(substitute(expr), ex$ex)
  ex
}
make_functions <- function(ex, args) {
  results <- vector("list", length = lst_length(ex$ex))
  i <- 1; lst <- ex$ex
  while (!is.null(lst)) {
    results[[i]] <- rlang::new_function(args, lst$car, rlang::caller_env())
    i <- i + 1
    lst <- lst$cdr
  }
  rev(results)
}

## ---- error=TRUE---------------------------------------------------------
make_line_expressions(intercept = 0) %>% eval_line(coef = 1)

## ------------------------------------------------------------------------
rlang::quos(x, y, x+y)

## ------------------------------------------------------------------------
f <- function(...) rlang::quos(...)
f(x, y, z)

## ------------------------------------------------------------------------
df <- tribble(
  ~x, ~y,
   1,  1,
  NA,  2,
   3,  3,
   4, NA,
   5,  5,
  NA,  6,
   7, NA
)
df %>% dplyr::filter(!is.na(x))
df %>% dplyr::filter(!is.na(y))

## ------------------------------------------------------------------------
filter_on_na <- function(df, column) {
  column <- substitute(column)
  df %>% dplyr::filter(!is.na(column))
}
df %>% filter_on_na(x)

## ------------------------------------------------------------------------
filter_on_na <- function(df, column) {
  column <- rlang::enexpr(column)
  df %>% dplyr::filter(!is.na(!!column))
}
df %>% filter_on_na(x)
df %>% filter_on_na(y)

## ------------------------------------------------------------------------
f <- function(x) substitute(x)
g <- function(x) rlang::enexpr(x)

## ------------------------------------------------------------------------
h <- function(func, var) func(!!var)
h(f, quote(x))
h(g, quote(x))

## ------------------------------------------------------------------------
x <- y <- 1
quote(2 * x + !!y)
rlang::expr(2 * x + !!y)
rlang::quo(2 * x + !!y)

## ------------------------------------------------------------------------
x <- y <- 2
rlang::expr(!!x + y)

## ------------------------------------------------------------------------
rlang::expr(UQ(x) + y)

## ------------------------------------------------------------------------
f <- function(df, summary_name, summary_expr) {
  summary_name <- rlang::enexpr(summary_name)
  summary_expr <- rlang::enquo(summary_expr)
  df %>% mutate(UQ(summary_name) := UQ(summary_expr))
}
tibble(x = 1:4, y = 1:4) %>% f(z, x + y)

## ------------------------------------------------------------------------
args <- rlang::quos(x = 1, y = 2)
q <- rlang::expr(f(rlang::UQS(args)))
q

## ------------------------------------------------------------------------
q <- rlang::expr(f(rlang::UQ(args)))
q

## ------------------------------------------------------------------------
q <- rlang::expr(f(!!!args))
q

## ------------------------------------------------------------------------
mean_expr <- function(ex, ...) {
  ex <- rlang::enquo(ex)
  extra_args <- rlang::dots_list(...)
  mean_call <- rlang::expr(with(
      data,
      mean(!!rlang::get_expr(ex), !!!extra_args))
  )
  rlang::new_function(args = alist(data=), 
                      body = mean_call,
                      env = rlang::get_env(ex))
}
mean_sum <- mean_expr(x + y, na.rm = TRUE)
mean_sum

## ------------------------------------------------------------------------
df
mean_sum(df)

## ------------------------------------------------------------------------
f <- function(z) mean_expr(x + y + z, na.rm = TRUE, trim = 0.1)
g <- f(z = 1:7)
g
g(df)

## ------------------------------------------------------------------------
f <- function(expr) rlang::enquo(expr)
g <- function(expr) f(rlang::enquo(expr))
f(x + y)
g(x + y)
rlang::eval_tidy(f(x + y), list(x = 1, y = 2))
rlang::eval_tidy(g(x + y), list(x = 1, y = 2))

