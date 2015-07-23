
#
# AUTO_GENERATED: 2015-07-22 16:10:04 -0700
# Pseudo-module which includes all modules exported as part of kryptnostic.
# This file is for optimizer build purposes only and should not be required or edited.
#

EXPORTED_MODULES = [
  # library
  # =======
  'bluebird'
  'forge'
  'jquery'
  'lodash'
  'loglevel'
  'pako'
  'require'
  'revalidator'

  # kryptnostic
  # =======
  'cs!auth/AuthenticationService'
  'cs!auth/CredentialLoader'
  'cs!auth/CredentialProviderLoader'
  'cs!auth/CredentialService'
  'cs!auth/credential-provider/InMemoryCredentialProvider'
  'cs!auth/credential-provider/KeyValueCredentialProvider'
  'cs!auth/credential-provider/LocalStorageCredentialProvider'
  'cs!auth/credential-provider/SessionStorageCredentialProvider'
  'cs!chunking/ChunkingStrategyRegistry'
  'cs!chunking/DefaultChunkingStrategy'
  'cs!crypto/AbstractCryptoService'
  'cs!crypto/AesCryptoService'
  'cs!crypto/CryptoAlgorithm'
  'cs!crypto/CryptoServiceLoader'
  'cs!crypto/CryptoServiceMarshaller'
  'cs!crypto/Cypher'
  'cs!crypto/HashFunction'
  'cs!crypto/KeypairSerializer'
  'cs!crypto/PasswordCryptoService'
  'cs!crypto/RsaCryptoService'
  'cs!http/DirectoryApi'
  'cs!http/ObjectApi'
  'cs!http/SharingApi'
  'cs!marshalling/DeflatingMarshaller'
  'cs!model/crypto/PublicKeyEnvelope'
  'cs!model/object/BlockCiphertext'
  'cs!model/object/EncryptedBlock'
  'cs!model/object/KryptnosticObject'
  'cs!model/object/ObjectMetadata'
  'cs!model/request/PendingObjectRequest'
  'cs!model/request/SharingRequest'
  'cs!model/request/StorageRequest'
  'cs!model/schema/block-ciphertext'
  'cs!model/schema/encrypted-block'
  'cs!model/schema/kryptnostic-object'
  'cs!model/schema/object-metadata'
  'cs!model/schema/pending-object-request'
  'cs!model/schema/sharing-request'
  'cs!model/schema/storage-request'
  'cs!model/schema/validator'
  'cs!service/BlockEncryptionService'
  'cs!service/ConfigurationService'
  'cs!service/SharingClient'
  'cs!service/StorageClient'
  'cs!tree/DeletionVisitor'
  'cs!tree/TreeLoader'
  'cs!tree/TreeNode'
  'cs!util/Logger'
  'cs!util/object-utils'
  'cs!util/security-utils'
  'cs!util/user-utils'
]


define('kryptnostic', EXPORTED_MODULES, (require) ->
  'use strict'
  return {}
)
