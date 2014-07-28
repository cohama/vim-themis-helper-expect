let s:save_cpo = &cpo
set cpo&vim

let s:expect = {
\ '_negate' : 0,
\ 'not' : {
\   '_negate' : 1
\ }}

function! themis#helper#expect#_create_expect(actual)
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
  let s:fid += 1
  if type(a:predicate) ==# type('')
    let s:Pre{s:fid} = s:expr_to_func(a:predicate)
  elseif type(a:predicate) ==# type(function('function'))
    let s:Pre{s:fid} = a:predicate
  endif
  execute join([
  \ 'function! s:expect.' . a:name . '(...) dict',
  \ '  return call("s:matcher_impl", ['. string(a:name) . ', s:Pre' . s:fid . '] + a:000, self)',
  \ 'endfunction'], "\n")
  let s:expect.not[a:name] = s:expect[a:name]
endfunction

call themis#helper#expect#define_matcher('to_be_true', 'v:actual is 1')
call themis#helper#expect#define_matcher('to_be_false', 'v:actual is 0')
call themis#helper#expect#define_matcher('to_be_truthy', '(type(v:actual) == type(0) || type(v:actual) == type("")) && v:actual')
call themis#helper#expect#define_matcher('to_be_falsy', '(type(v:actual) != type(0) || type(v:actual) != type("")) && !v:actual')
call themis#helper#expect#define_matcher('to_equal', 'v:actual ==# v:expected')
call themis#helper#expect#define_matcher('to_be_same', 'v:actual is v:expected')
call themis#helper#expect#define_matcher('to_match', 'type(v:actual) == type("") && type(v:expected) == type("") && v:actual =~# v:expected')

call themis#helper#expect#define_matcher('to_be_number', 'type(v:actual) ==# type(0)')
call themis#helper#expect#define_matcher('to_be_string', 'type(v:actual) ==# type("")')
call themis#helper#expect#define_matcher('to_be_func', 'type(v:actual) ==# type(function("function"))')
call themis#helper#expect#define_matcher('to_be_list', 'type(v:actual) ==# type([])')
call themis#helper#expect#define_matcher('to_be_dict', 'type(v:actual) ==# type({})')
call themis#helper#expect#define_matcher('to_be_float', 'type(v:actual) ==# type(0.0)')
call themis#helper#expect#define_matcher('to_exist', function('exists'))
call themis#helper#expect#define_matcher('to_have_key', function('has_key'))
function! themis#helper#expect#new(_)
  return function('themis#helper#expect#_create_expect')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
