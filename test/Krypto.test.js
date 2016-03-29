import { Krypto } from 'exports?Krypto=Module.KryptnosticClient!krypto-js';

describe('Krypto', () => {

  it('should correctly import Krypto from KryptoJS', () => {

    expect(Krypto).toBeDefined();
    expect(new Krypto()).toBeDefined();
  });

});
