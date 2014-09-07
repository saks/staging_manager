nock     = require 'nock'
mongoose = require 'mongoose'
User     = mongoose.model 'User'

describe 'User model', ->
  afterEach (done) ->
    nock.disableNetConnect()
    done()

  describe 'verbose name', ->
    it 'should return name if possible', (done) ->
      Factory.create 'user', (user) ->
        expect(user.verboseName()).to.eql user.name
        done()

    it 'should return email if no name', (done) ->
      Factory.create 'user', name: undefined, (user) ->
        expect(user.verboseName()).to.eql user.email
        done()

    it 'should return at least login', (done) ->
      Factory.create 'user', name: undefined, email: undefined, (user) ->
        expect(user.verboseName()).to.eql user.login
        done()

  it 'should create user by github login', (done) ->
    githubUser =
      id:    123
      name:  'user-name'
      email: 'user@email.com'
      login: 'user-login'

    nock 'https://api.github.com'
      .get "/users/#{githubUser.login}"
      .reply 200, githubUser

    User.createByGithubLogin githubUser.login, (error, user) ->
      expect(error).to.not.exist

      expect(user).to.exist
      expect(user).have.property('github_user_id').eql githubUser.id
      expect(user).have.property('name').eql githubUser.name
      expect(user).have.property('login').eql githubUser.login
      expect(user).have.property('email').eql githubUser.email

      done()

  describe 'userByGithubLogin', ->
    it 'shold return existing user', (done) ->
      nock.disableNetConnect()

      Factory.create 'user', (user) ->
        User.userByGithubLogin user.login, (error, userFromDb) ->
          expect(userFromDb.toObject()).to.eql user.toObject()
          done()

    it 'should create new user if not exists', (done) ->
      githubUser =
        id:    123
        name:  'user-name'
        email: 'user@email.com'
        login: 'user-login'

      nock 'https://api.github.com'
        .get "/users/#{githubUser.login}"
        .reply 200, githubUser

      User.userByGithubLogin githubUser.login, (error, user) ->
        expect(error).to.not.exist

        expect(user).to.exist
        expect(user).have.property('github_user_id').eql githubUser.id
        expect(user).have.property('name').eql githubUser.name
        expect(user).have.property('login').eql githubUser.login
        expect(user).have.property('email').eql githubUser.email

        done()
