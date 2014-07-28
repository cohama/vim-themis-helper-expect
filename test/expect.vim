let s:suite = themis#suite('themis expect helper')
let s:expect = themis#helper#expect#new('expect')

function! s:suite.expect_helper_success()
  call s:expect(1).to_be_true()
  call s:expect(0).to_be_false()
  call s:expect('2').to_be_truthy()
  call s:expect('').to_be_falsy()
  call s:expect('hoge').to_equal('hoge')
  let xs = [1,2,3]
  call s:expect(xs).to_be_same(xs)
  call s:expect('hoge-fuga').to_match('^\w\+-\w\+$')
  call s:expect(1).to_be_number()
  call s:expect('j').to_be_string()
  call s:expect(s:expect).to_be_func()
  call s:expect([]).to_be_list()
  call s:expect({}).to_be_dict()
  call s:expect(1.3).to_be_float()
  let g:hoge = 1
  call s:expect('g:hoge').to_exist()
  unlet g:hoge
  let dict = {"fuga" : 1}
  call s:expect(dict).to_have_key('fuga')
endfunction

function! s:suite.expect_not_helper_success()
  call s:expect('0').not.to_be_truthy()
  call s:expect('1').not.to_be_falsy()
  call s:expect('fuga').not.to_equal('hoge')
  let xs = [1,2,3]
  call s:expect(xs).not.to_be_same([1,2,3])
  call s:expect('hoge-fuga').not.to_match('^\w\+$')
  call s:expect(1.0).not.to_be_number()
  call s:expect(['j']).not.to_be_string()
  call s:expect(s:suite).not.to_be_func()
  call s:expect({}).not.to_be_list()
  call s:expect([]).not.to_be_dict()
  call s:expect(1).not.to_be_float()
  call s:expect('g:fuga').not.to_exist()
  let dict = {"fuga" : 1}
  call s:expect(dict).not.to_have_key('piyo')
endfunction
