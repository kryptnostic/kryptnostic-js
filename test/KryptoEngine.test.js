import KryptoEngine from '../src/KryptoEngine';

const FHE_SEARCH_PRIVATE_KEY_SIZE = 4096;
const FHE_PRIVATE_KEY_SIZE = 329760;
const FHE_HASH_FUNCTION_SIZE = 1060896;

KryptoEngine.init();
const engine = KryptoEngine.getEngine();

describe('KryptoEngine', () => {

  it('should generate a valid FHE private key', () => {

    const fhePrivateKey = engine.getFHEPrivateKey();
    expect(fhePrivateKey instanceof Uint8Array).toBe(true);
    expect(fhePrivateKey.length).toEqual(FHE_PRIVATE_KEY_SIZE);
  });

  it('should generate a valid FHE search private key', () => {

    const fheSearchPrivateKey = engine.getFHESearchPrivateKey();
    expect(fheSearchPrivateKey instanceof Uint8Array).toBe(true);
    expect(fheSearchPrivateKey.length).toEqual(FHE_SEARCH_PRIVATE_KEY_SIZE);
  });

  it('should generate a valid FHE hash function', () => {

    const fheHashFunction = engine.getFHEHashFunction();
    expect(fheHashFunction instanceof Uint8Array).toBe(true);
    expect(fheHashFunction.length).toEqual(FHE_HASH_FUNCTION_SIZE);
  });

});
