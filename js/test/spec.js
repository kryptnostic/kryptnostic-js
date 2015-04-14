define(['src/aes-crypto-service', 'src/crypto-service-loader'], function(CryptoService, CryptoServiceLoader) {
    describe('crypto service test', function() {
        it('can run a test', function() {
            expect(true).toBe(true);
            // console.log(CryptoService);
        });
    });

    describe('crypto services loader test', function() {
        it('can run a test', function() {
          CryptoServiceLoader.get("12");
        });
    });
});