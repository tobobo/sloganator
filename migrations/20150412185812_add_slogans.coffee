
exports.up = (knex, Promise) ->
  knex.schema.createTable 'slogans', (t) ->
    t.increments('id').primary()
    t.string 'slogan'
    t.string 'user'
    t.timestamps()


exports.down = (knex, Promise) ->
  knex.schema.dropTable 'slogans'
