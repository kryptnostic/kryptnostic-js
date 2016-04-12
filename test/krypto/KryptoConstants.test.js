import * as KryptoConstants from '../../src/KryptoConstants';

function testForConstant(constant, expectedValue) {

  it('should be defined', () => {

    expect(constant).toBeDefined();
  });

  it(`should be ${expectedValue}`, () => {

    expect(constant).toBe(expectedValue);
  });
}

describe('KryptoConstants', () => {

  describe('FHE_PRIVATE_KEY_SIZE', () => {

    testForConstant(KryptoConstants.FHE_PRIVATE_KEY_SIZE, 329760);
  });

  describe('FHE_SEARCH_PRIVATE_KEY_SIZE', () => {

    testForConstant(KryptoConstants.FHE_SEARCH_PRIVATE_KEY_SIZE, 4096);
  });

  describe('FHE_HASH_FUNCTION_SIZE', () => {

    testForConstant(KryptoConstants.FHE_HASH_FUNCTION_SIZE, 1060896);
  });

  describe('OBJECT_INDEX_PAIR_SIZE', () => {

    testForConstant(KryptoConstants.OBJECT_INDEX_PAIR_SIZE, 2064);
  });

  describe('OBJECT_SEARCH_PAIR_SIZE', () => {

    testForConstant(KryptoConstants.OBJECT_SEARCH_PAIR_SIZE, 2080);
  });

  describe('OBJECT_SHARE_PAIR_SIZE', () => {

    testForConstant(KryptoConstants.OBJECT_SHARE_PAIR_SIZE, 2064);
  });

  describe('ENCRYPTED_SEARCH_TOKEN_SIZE', () => {

    testForConstant(KryptoConstants.ENCRYPTED_SEARCH_TOKEN_SIZE, 32);
  });

  describe('METADATA_ADDRESS_SIZE', () => {

    testForConstant(KryptoConstants.METADATA_ADDRESS_SIZE, 16);
  });

});
