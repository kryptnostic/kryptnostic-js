define [
  'require'
  'sinon'
  'bluebird'
  'soteria.tree-loader'
  'soteria.logger'
  'soteria.credential-loader'
], (require) ->

  MOCK_CREDS = { principal: 'krypt|demo', credential: 'fake', keypair: {}}

  Logger           = require 'soteria.logger'
  TreeLoader       = require 'soteria.tree-loader'
  sinon            = require 'sinon'
  Promise          = require 'bluebird'
  CredentialLoader = require 'soteria.credential-loader'

  log = Logger.get('TreeLoader')

  # mock data
  # =========

  NODE_1   = '1'
  NODE_1_0 = '1~0'
  NODE_2   = '2'
  NODE_2_0 = '2~0'
  NODE_2_2 = '2~2'
  NODE_3   = '3'

  MOCK_METADATA_BY_MOCK_ID           = { }
  MOCK_METADATA_BY_MOCK_ID[NODE_1]   = { childObjectCount: 1 }
  MOCK_METADATA_BY_MOCK_ID[NODE_1_0] = { childObjectCount: 0 }
  MOCK_METADATA_BY_MOCK_ID[NODE_2]   = { childObjectCount: 3 }
  MOCK_METADATA_BY_MOCK_ID[NODE_2_0] = { childObjectCount: 0 }
  MOCK_METADATA_BY_MOCK_ID[NODE_2_2] = { childObjectCount: 0 }

  # setup
  # =====

  {treeLoader} = {}

  beforeEach ->
    treeLoader = new TreeLoader()
    sinon.stub(treeLoader.objectApi, 'getObjectMetadata', (id) ->
      metadata = MOCK_METADATA_BY_MOCK_ID[id]

      if metadata?
        return Promise.resolve(metadata)
      else
        return Promise.reject('simulated 404 - object does not exist')
    )
    sinon.stub(CredentialLoader, 'getCredentials').returns(MOCK_CREDS)

  afterEach ->
    treeLoader.objectApi.getObjectMetadata.restore()
    CredentialLoader.getCredentials.restore()

  # tests
  # =====

  describe 'TreeLoader', ->

    describe '#load', ->

      it 'should load a full tree', (done) ->
        treeLoader.load(NODE_1)
        .then (tree) ->
          expect(tree).toBeDefined()
          expect(tree.id).toBe(NODE_1)
          expect(tree.children.length).toBe(1)
          expect(_.first(tree.children).id).toBe(NODE_1_0)
          done()

      it 'should load a full tree with a deleted child node', (done) ->
        treeLoader.load(NODE_2)
        .then (tree) ->
          expect(tree).toBeDefined()
          expect(tree.id).toBe(NODE_2)
          expect(tree.children.length).toBe(2)
          expect(_.first(tree.children).id).toBe(NODE_2_0)
          expect(_.last(tree.children).id).toBe(NODE_2_2)
          done()

      it 'should return undefined on nonexistant node', (done) ->
        treeLoader.load(NODE_3)
        .then (tree) ->
          expect(tree).toBeUndefined()
          done()
