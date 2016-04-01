import KryptoEngine from '../../src/KryptoEngine';

describe('KryptoEngine', () => {

  it('should behave like a singleton', () => {

    expect(KryptoEngine.getEngine).toThrow();
    expect(KryptoEngine.init).not.toThrow();
    expect(KryptoEngine.getEngine).not.toThrow();
    expect(KryptoEngine.init).toThrow();
    expect(KryptoEngine.getEngine()).toBeDefined();
  });

  it('should only export init() and getEngine()', () => {

    expect(Object.keys(KryptoEngine).length).toEqual(2);
    expect(KryptoEngine.init).toBeDefined();
    expect(KryptoEngine.getEngine).toBeDefined();
  });

});
