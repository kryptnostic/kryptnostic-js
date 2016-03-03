var path = require('path');
var webpack = require('webpack');

var ENTRY_POINT = 'kryptnostic-umd-exports.js';
var KJS_LIBRARY_FILE_NAME = 'kryptnostic.umd.js';

var SOURCE_PATH = path.resolve(__dirname, 'js/src');
var DIST_PATH = path.resolve(__dirname, 'dist');
var BOWER_PATH = path.resolve(__dirname, 'bower_components');
var NODE_PATH = path.resolve(__dirname, 'node_modules');

var AXIOS_PATH = path.resolve('bower_components/axios/dist/axios.js');
var FORGE_PATH = path.resolve('bower_components/forge/js/forge.bundle.js');

module.exports = {
  context: SOURCE_PATH,
  entry: ENTRY_POINT,
  output: {
    path: DIST_PATH,
    filename: KJS_LIBRARY_FILE_NAME,
    libraryTarget: 'umd'
  },
  module: {
    loaders: [
      {
        test: /\.coffee$/,
        loader: 'coffee'
      }
    ]
  },
  plugins: [
    new webpack.ResolverPlugin(
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin('bower.json', ['main'])
    )
  ],
  resolve: {
    root: [
      SOURCE_PATH,
      BOWER_PATH,
      NODE_PATH
    ],
    extensions: ['', '.js', '.coffee'],
    alias: {
      'axios': AXIOS_PATH,
      'forge': FORGE_PATH,

      'kryptnostic.authentication-service'              : 'auth/AuthenticationService.coffee',
      'kryptnostic.authentication-stage'                : 'auth/AuthenticationStage.coffee',
      'kryptnostic.credential-loader'                   : 'auth/CredentialLoader.coffee',
      'kryptnostic.credential-provider-loader'          : 'auth/CredentialProviderLoader.coffee',
      'kryptnostic.credential-service'                  : 'auth/CredentialService.coffee',
      'kryptnostic.salt-generator'                      : 'auth/SaltGenerator.coffee',
      'kryptnostic.search-credential-service'           : 'auth/SearchCredentialService.coffee',
      'kryptnostic.search-key-serializer'               : 'auth/SearchKeySerializer.coffee',
      'kryptnostic.credential-provider.memory'          : 'auth/credential-provider/InMemoryCredentialProvider.coffee',
      'kryptnostic.credential-provider.key-value'       : 'auth/credential-provider/KeyValueCredentialProvider.coffee',
      'kryptnostic.credential-provider.local-storage'   : 'auth/credential-provider/LocalStorageCredentialProvider.coffee',
      'kryptnostic.credential-provider.session-storage' : 'auth/credential-provider/SessionStorageCredentialProvider.coffee',
      'kryptnostic.chunking.registry'                   : 'chunking/ChunkingStrategyRegistry.coffee',
      'kryptnostic.chunking.strategy.default'           : 'chunking/DefaultChunkingStrategy.coffee',
      'kryptnostic.chunking.strategy.json'              : 'chunking/JsonChunkingStrategy.coffee',
      'kryptnostic.abstract-crypto-service'             : 'crypto/AbstractCryptoService.coffee',
      'kryptnostic.aes-crypto-service'                  : 'crypto/AesCryptoService.coffee',
      'kryptnostic.crypto-algorithm'                    : 'crypto/CryptoAlgorithm.coffee',
      'kryptnostic.crypto-material'                     : 'crypto/CryptoMaterial.coffee',
      'kryptnostic.crypto-service-loader'               : 'crypto/CryptoServiceLoader.coffee',
      'kryptnostic.crypto-service-marshaller'           : 'crypto/CryptoServiceMarshaller.coffee',
      'kryptnostic.crypto-service-migrator'             : 'crypto/CryptoServiceMigrator.coffee',
      'kryptnostic.cypher'                              : 'crypto/Cypher.coffee',
      'kryptnostic.hash-function'                       : 'crypto/HashFunction.coffee',
      'kryptnostic.keypair-serializer'                  : 'crypto/KeypairSerializer.coffee',
      'kryptnostic.password-crypto-service'             : 'crypto/PasswordCryptoService.coffee',
      'kryptnostic.rsa-crypto-service'                  : 'crypto/RsaCryptoService.coffee',
      'kryptnostic.rsa-key-generator'                   : 'crypto/RsaKeyGenerator.coffee',
      'kryptnostic.kryptnostic-engine'                  : 'engine/KryptnosticEngine.coffee',
      'kryptnostic.kryptnostic-engine-provider'         : 'engine/KryptnosticEngineProvider.coffee',
      'kryptnostic.search-key-generator'                : 'engine/SearchKeyGenerator.coffee',
      'kryptnostic.key-storage-api'                     : 'http/KeyStorageApi.coffee',
      'kryptnostic.metadata-api'                        : 'http/MetadataApi.coffee',
      'kryptnostic.object-api'                          : 'http/ObjectApi.coffee',
      'kryptnostic.object-authorization-api'            : 'http/ObjectAuthorizationApi.coffee',
      'kryptnostic.object-listing-api'                  : 'http/ObjectListingApi.coffee',
      'kryptnostic.registration-api'                    : 'http/RegistrationApi.coffee',
      'kryptnostic.search-api'                          : 'http/SearchApi.coffee',
      'kryptnostic.sharing-api'                         : 'http/SharingApi.coffee',
      'kryptnostic.user-directory-api'                  : 'http/UserDirectoryApi.coffee',
      'kryptnostic.inverted-index-segment'              : 'indexing/InvertedIndexSegment.coffee',
      'kryptnostic.object-indexer'                      : 'indexing/ObjectIndexer.coffee',
      'kryptnostic.object-indexing-service'             : 'indexing/ObjectIndexingService.coffee',
      'kryptnostic.object-tokenizer'                    : 'indexing/ObjectTokenizer.coffee',
      'kryptnostic.deflating-marshaller'                : 'marshalling/DeflatingMarshaller.coffee',
      'kryptnostic.block-ciphertext'                    : 'model/object/BlockCiphertext.coffee',
      'kryptnostic.encrypted-block'                     : 'model/object/EncryptedBlock.coffee',
      'kryptnostic.kryptnostic-object'                  : 'model/object/KryptnosticObject.coffee',
      'kryptnostic.object-metadata'                     : 'model/object/ObjectMetadata.coffee',
      'kryptnostic.object-metadata-tree'                : 'model/object/ObjectMetadataTree.coffee',
      'kryptnostic.create-object-request'               : 'model/request/CreateObjectRequest.coffee',
      'kryptnostic.metadata-request'                    : 'model/request/MetadataRequest.coffee',
      'kryptnostic.object-tree-load-request'            : 'model/request/ObjectTreeLoadRequest.coffee',
      'kryptnostic.revocation-request'                  : 'model/request/RevocationRequest.coffee',
      'kryptnostic.search-request'                      : 'model/request/SearchRequest.coffee',
      'kryptnostic.sharing-request'                     : 'model/request/SharingRequest.coffee',
      'kryptnostic.storage-request'                     : 'model/request/StorageRequest.coffee',
      'kryptnostic.user-registration-request'           : 'model/request/UserRegistrationRequest.coffee',
      'kryptnostic.schema.block-ciphertext'             : 'model/schema/block-ciphertext.coffee',
      'kryptnostic.schema.create-object-request'        : 'model/schema/create-object-request.coffee',
      'kryptnostic.schema.encryptable'                  : 'model/schema/encryptable.coffee',
      'kryptnostic.schema.encrypted-block'              : 'model/schema/encrypted-block.coffee',
      'kryptnostic.schema.indexed-metadata'             : 'model/schema/indexed-metadata.coffee',
      'kryptnostic.schema.inverted-index-segment'       : 'model/schema/inverted-index-segment.coffee',
      'kryptnostic.schema.kryptnostic-object'           : 'model/schema/kryptnostic-object.coffee',
      'kryptnostic.schema.object-metadata'              : 'model/schema/object-metadata.coffee',
      'kryptnostic.schema.object-metadata-tree'         : 'model/schema/object-metadata-tree.coffee',
      'kryptnostic.schema.object-tree-load-request'     : 'model/schema/object-tree-load-request.coffee',
      'kryptnostic.schema.pending-object-request'       : 'model/schema/pending-object-request.coffee',
      'kryptnostic.schema.revocation-request'           : 'model/schema/revocation-request.coffee',
      'kryptnostic.schema.search-request'               : 'model/schema/search-request.coffee',
      'kryptnostic.schema.sharing-request'              : 'model/schema/sharing-request.coffee',
      'kryptnostic.schema.storage-request'              : 'model/schema/storage-request.coffee',
      'kryptnostic.schema.user-registration-request'    : 'model/schema/user-registration-request.coffee',
      'kryptnostic.schema.validator'                    : 'model/schema/validator.coffee',
      'kryptnostic.indexed-metadata'                    : 'model/search/IndexedMetadata.coffee',
      'kryptnostic.random-index-generator'              : 'search/RandomIndexGenerator.coffee',
      'kryptnostic.search-client'                       : 'search/SearchClient.coffee',
      'kryptnostic.block-encryption-service'            : 'service/BlockEncryptionService.coffee',
      'kryptnostic.configuration'                       : 'service/ConfigurationService.coffee',
      'kryptnostic.registration-client'                 : 'service/RegistrationClient.coffee',
      'kryptnostic.sharing-client'                      : 'service/SharingClient.coffee',
      'kryptnostic.storage-client'                      : 'service/StorageClient.coffee',
      'kryptnostic.caching-provider-loader'             : 'service/caching-provider/CachingProviderLoader.coffee',
      'kryptnostic.caching-service'                     : 'service/caching-provider/CachingService.coffee',
      'kryptnostic.caching-provider.memory'             : 'service/caching-provider/InMemoryCachingProvider.coffee',
      'kryptnostic.caching-provider.jscache'            : 'service/caching-provider/JscacheCachingProvider.coffee',
      'kryptnostic.permission-change-visitor'           : 'tree/PermissionChangeVisitor.coffee',
      'kryptnostic.tree-loader'                         : 'tree/TreeLoader.coffee',
      'kryptnostic.tree-node'                           : 'tree/TreeNode.coffee',
      'kryptnostic.logger'                              : 'util/Logger.coffee',
      'kryptnostic.binary-utils'                        : 'util/binary-utils.coffee',
      'kryptnostic.object-utils'                        : 'util/object-utils.coffee',
      'kryptnostic.requests'                            : 'util/requests.coffee',
      'kryptnostic.validators'                          : 'util/validators.coffee',
      'kryptnostic.kryptnostic-workers-api'             : 'workers/KryptnosticWorkersApi.coffee',
      'kryptnostic.fhe-keys-gen-worker-wrapper'         : 'workers/FHEKeysGenerationWorkerWrapper',
      'kryptnostic.kryptnostic-workers-api'             : 'workers/KryptnosticWorkersApi',
      'kryptnostic.object-indexing-worker-wrapper'      : 'workers/ObjectIndexingWorkerWrapper',
      'kryptnostic.rsa-keys-gen-worker-wrapper'         : 'workers/RSAKeysGenerationWorkerWrapper',
      'kryptnostic.worker-wrapper'                      : 'workers/WorkerWrapper'
    }
  }
}
