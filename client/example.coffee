usernameInput = $ 'input.username'

usernameInput.on 'focus', =>
  usernameInput[0].select()

usernameInput.on 'keydown', (e) =>
  if e.keyCode == 32 then return e.preventDefault() # spacebar
  if e.keyCode == 8 then return # delete
  setTimeout ->
    $('span.welcome strong a').html usernameInput.val()
  , 1

$('input.sloganator-input').on 'keydown', (e) ->
  if e.keyCode == 13
    usernameInput.val ''
