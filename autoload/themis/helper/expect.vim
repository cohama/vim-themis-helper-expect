let s:save_cpo = &cpo
set cpo&vim

let s:expect = {}
let s:expect.not = {}
let s:assert = themis#helper#assert#new('assert')

function! s:create_expect(actual)
  let expect = deepcopy(s:expect)
  let expect.actual = a:actual
  let expect.not.actual = a:actual
  return expect
endfunction

let s:translate_table = {
\ 'skip'         : s:assert.skip,
\ 'todo'         : s:assert.todo,
\ 'to_be_true'   : s:assert.true,
\ 'to_be_false'  : s:assert.false,
\ 'to_be_truthy' : s:assert.truthy,
\ 'to_be_falsy'  : s:assert.falsy,
\ 'to_equal'     : s:assert.equals,
\ 'to_be_same'   : s:assert.same,
\ 'to_match'     : s:assert.match,
\ 'to_be_number' : s:assert.is_number,
\ 'to_be_string' : s:assert.is_string,
\ 'to_be_func'   : s:assert.is_func,
\ 'to_be_list'   : s:assert.is_list,
\ 'to_be_dict'   : s:assert.is_dict,
\ 'to_be_float'  : s:assert.is_float,
\ 'to_exist'     : s:assert.exists
\ }

let s:negate_table = {
\ 'to_be_truthy' : s:assert.falsy,
\ 'to_be_falsy'  : s:assert.truthy,
\ 'to_equal'     : s:assert.not_equals,
\ 'to_be_same'   : s:assert.not_same,
\ 'to_match'     : s:assert.not_match,
\ 'to_be_number' : s:assert.is_not_number,
\ 'to_be_string' : s:assert.is_not_string,
\ 'to_be_func'   : s:assert.is_not_func,
\ 'to_be_list'   : s:assert.is_not_list,
\ 'to_be_dict'   : s:assert.is_not_dict,
\ 'to_be_float'  : s:assert.is_not_float
\ }
" 'to_exist'     : s:assert.not_exists

for key in keys(s:translate_table)
  execute join([
  \ 'function! s:expect.' . key . '(...) dict',
  \ '  let args = [self.actual] + a:000',
  \ '  return call(s:translate_table.' . key . ', args, {})',
  \ 'endfunction'], "\n")
endfor
unlet key


for key in keys(s:negate_table)
  execute join([
  \ 'function! s:expect.not.' . key . '(...) dict',
  \ '  let args = insert(deepcopy(a:000), self.actual)',
  \ '  return call(s:negate_table.' . key . ', args, {})',
  \ 'endfunction'], "\n")
endfor


function! themis#helper#expect#new(_)
  return function('s:create_expect')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
