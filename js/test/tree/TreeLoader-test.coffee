define [
  'require'
  'sinon'
  'bluebird'
  'kryptnostic.tree-loader'
  'kryptnostic.logger'
], (require) ->

  MOCK_CREDS = { principal: 'krypt|demo', credential: 'fake', keypair: {} }

  Logger     = require 'kryptnostic.logger'
  TreeLoader = require 'kryptnostic.tree-loader'
  sinon      = require 'sinon'
  Promise    = require 'bluebird'

  log = Logger.get('TreeLoader')

  # mock data
  # =========

  NODE_1   = '1'
  NODE_1_0 = '1~0'

  NODE_2   = '2'
  NODE_2_0 = '2~0'
  NODE_2_2 = '2~2'

  NODE_3   = '3'

  NODE_4     = '4'
  NODE_4_0   = '4~0'
  NODE_4_0_0 = '4~0~0'

  MOCK_METADATA_BY_MOCK_ID             = {}
  MOCK_METADATA_BY_MOCK_ID[NODE_1]     = { childObjectCount: 1 }
  MOCK_METADATA_BY_MOCK_ID[NODE_1_0]   = { childObjectCount: 0 }
  MOCK_METADATA_BY_MOCK_ID[NODE_2]     = { childObjectCount: 3 }
  MOCK_METADATA_BY_MOCK_ID[NODE_2_0]   = { childObjectCount: 0 }
  MOCK_METADATA_BY_MOCK_ID[NODE_2_2]   = { childObjectCount: 0 }
  MOCK_METADATA_BY_MOCK_ID[NODE_4]     = { childObjectCount: 1 }
  MOCK_METADATA_BY_MOCK_ID[NODE_4_0]   = { childObjectCount: 1 }
  MOCK_METADATA_BY_MOCK_ID[NODE_4_0_0] = { childObjectCount: 0 }


  # setup
  # =====

  { treeLoader } = {}

  beforeEach ->
    treeLoader = new TreeLoader()
    sinon.stub(treeLoader.objectApi, 'getObjectMetadata', (id) ->
      metadata = MOCK_METADATA_BY_MOCK_ID[id]

      if metadata?
        return Promise.resolve(metadata)
      else
        return Promise.reject('simulated 404 - object does not exist')
    )
    sinon.stub(treeLoader.objectApi, 'wrapCredentials', (request, credentials) -> return request )

  afterEach ->
    treeLoader.objectApi.getObjectMetadata.restore()
    treeLoader.objectApi.wrapCredentials.restore()

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

      it 'should load a tree with depth constraint 1', (done) ->
        treeLoader.load(NODE_4, { depth: 1 })
        .then (tree) ->
          expect(tree).toBeDefined()
          expect(tree.id).toBe(NODE_4)
          expect(tree.children.length).toBe(1)
          expect(_.first(tree.children).id).toBe(NODE_4_0)
          expect(_.first(tree.children).children.length).toBe(0)
          done()

      it 'should load a tree with depth constraint 2', (done) ->
        treeLoader.load(NODE_4, { depth: 2 })
        .then (tree) ->
          expect(tree).toBeDefined()
          expect(tree.id).toBe(NODE_4)
          expect(tree.children.length).toBe(1)
          expect(_.first(tree.children).id).toBe(NODE_4_0)
          expect(_.first(tree.children).children.length).toBe(1)
          expect(_.first(_.first(tree.children).children).id).toBe(NODE_4_0_0)
          done()
