import KryptoEngine from '../../src/krypto/KryptoEngine';

describe('KryptoEngine - Singleton', () => {

  it('should not expose private KryptoEngine instance', () => {

    expect(KryptoEngine.kryptoEngineInstance).not.toBeDefined();
  });

  it('should only export init() and getEngine()', () => {

    expect(Object.keys(KryptoEngine).length).toEqual(2);
    expect(KryptoEngine.init).toEqual(jasmine.any(Function));
    expect(KryptoEngine.getEngine).toEqual(jasmine.any(Function));
  });

  it('should behave like a singleton', () => {

    expect(KryptoEngine.getEngine).toThrow();
    expect(KryptoEngine.init).not.toThrow();
    expect(KryptoEngine.getEngine).not.toThrow();
    expect(KryptoEngine.init).toThrow();
    expect(KryptoEngine.getEngine()).toBeDefined();
  });

});
