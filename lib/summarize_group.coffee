config = require('../config')
levelup = require('levelup')
_ = require 'underscore'
moment = require 'moment'

# What different activities are worth.
# Points have a 1/2 life of six months. So if a member created a post
# exactly six months ago, that action is now worth 2.5 points.
COMMENT = 10
LIKE = 1
POST = 5

module.exports = (program) ->
  # Loop through all posts and comments and groups and assign points.
  postsDb = levelup(config.dataDir + '/group_' + program.group_id, { valueEncoding: 'json' })
  posts = 0
  post_chars = 0
  comments = 0
  comment_chars = 0
  likes = 0
  postsDb.createReadStream()
    .on('data', (data) ->
      post = data.value

      posts += 1
      if post.message?
        post_chars += post.message.length

      # Count likes.
      if post.likes?
        likes += post.likes.data.length

      # Count comments.
      if post.comments?
        for comment in post.comments.data
          comments += 1
          comment_chars += comment.message.length
    )
    # We've gone through every post, send the results to stdout.
    .on('end', ->
      console.log "Post: #{posts}"
      console.log "Post chars: #{post_chars}"
      console.log "Likes: #{likes}"
      console.log "Comments: #{comments}"
      console.log "Comment chars: #{comment_chars}"
    )
