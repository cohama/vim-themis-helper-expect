let s:save_cpo = &cpo
set cpo&vim

let s:expect = {
\ '_negate' : 0,
\ 'not' : {
\   '_negate' : 1
\ }}

let s:assert = themis#helper#assert#new('assert')

function! s:create_expect(actual)
  let expect = deepcopy(s:expect)
  let expect._actual = a:actual
  let expect.not._actual = a:actual
  return expect
endfunction

function! s:matcher_impl(name, f, ...) dict
  let result = call(a:f, [self._actual] + a:000)
  if self._negate
    let result = !result
  endif
  if result
    return {'and' : self}
  else
    throw printf('themis: report: failure: Expected %s %s%s%s.',
    \       string(self._actual),
    \       (self._negate ? 'not ' : ''),
    \       substitute(a:name, '_', ' ', 'g'),
    \       (a:0 > 0) ? (' ' . string(join(a:000, ', '))) : '')
  endif
endfunction

let s:fid = 0
function! s:expr_to_func(pred, ...)
  let pred = substitute(a:pred, 'v:actual', 'a:actual', 'g')
  let pred = substitute(pred, 'v:expected', 'expected', 'g')
  let s:fid += 1
  execute join([
  \ 'function! s:' . s:fid . '(actual, ...)',
  \ '  if a:0 > 0',
  \ '    let expected = a:1',
  \ '  endif',
  \ '  return ' . pred,
  \ 'endfunction'], "\n")
  return function('s:' . s:fid)
endfunction

function! themis#helper#expect#define_matcher(name, predicate)
  let fun_name = 's:expect_matcher_' . a:name
  if type(a:predicate) ==# type('')
    let {fun_name}_pre = s:expr_to_func(a:predicate)
  elseif type(a:predicate) ==# type(function('function'))
    let {fun_name}_pre = a:predicate
  endif
  execute join([
  \ 'function! ' . fun_name . '(...) dict',
  \ '  return call("s:matcher_impl", ['. string(a:name) . ', ' . fun_name . '_pre] + a:000, self)',
  \ 'endfunction'], "\n")
  let s:expect[a:name] = function(fun_name)
  let s:expect.not[a:name] = function(fun_name)
endfunction

call themis#helper#expect#define_matcher('to_be_true', 'v:actual is 1')
call themis#helper#expect#define_matcher('to_be_false', 'v:actual is 0')
call themis#helper#expect#define_matcher('to_be_truthy', '(type(v:actual) == type(0) || type(v:actual) == type("")) && v:actual')
call themis#helper#expect#define_matcher('to_be_falsy', '(type(v:actual) != type(0) || type(v:actual) != type("")) && !v:actual')
" call themis#helper#expect#define_matcher('to_equal', 'v:actual ==# v:expected')
call themis#helper#expect#define_matcher('to_be_same', 'v:actual is v:expected')
call themis#helper#expect#define_matcher('to_match', 'type(v:actual) == type("") && type(v:expected) == type("") && v:actual =~# v:expected')

function! s:is_number(actual)
  return type(a:actual) ==# type(0)
endfunction
call themis#helper#expect#define_matcher('to_be_number', function('s:is_number'))

function! s:are_equal(actual, expected)
  return a:actual ==# a:expected
endfunction
call themis#helper#expect#define_matcher('to_equal', 'v:actual ==# v:expected')

call themis#helper#expect#define_matcher('to_be_string', 'type(v:actual) ==# type("")')
call themis#helper#expect#define_matcher('to_be_func', 'type(v:actual) ==# type(function("function"))')
call themis#helper#expect#define_matcher('to_be_list', 'type(v:actual) ==# type([])')
call themis#helper#expect#define_matcher('to_be_dict', 'type(v:actual) ==# type({})')
call themis#helper#expect#define_matcher('to_be_float', 'type(v:actual) ==# type(0.0)')
call themis#helper#expect#define_matcher('to_exist', function('exists'))
function! themis#helper#expect#new(_)
  return function('s:create_expect')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
