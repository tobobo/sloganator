usernameInput = $ 'input.username'
usernameInput.on 'focus', =>
  usernameInput[0].select()
usernameInput.on 'keydown', (e) =>
  console.log e.keyCode
  if e.keyCode == 32 then return e.preventDefault() # spacebar
  if e.keyCode == 8 then return # delete
  setTimeout ->
    $('span.welcome strong a').html usernameInput.val()
  , 1
