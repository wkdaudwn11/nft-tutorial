const Color = artifacts.require('./Color.sol');

require('chai').use(require('chai-as-promised')).should()

contract('Color', (accounts) => {
    let contract;
    const name = "Color", symbol = "COLOR";

    before(async () => {
        contract = await Color.deployed(); // 배포 결과를 contract에다가 담기?
    })

    describe('deployment', async () => {
        it('배포 성공', async () => { 
            const address = contract.address; // 주소 담기

            // 유효한 주소값인지 체크 (이것들 한줄 한줄이 체크하는 것임. false를 리턴하면 테스트 실패)
            assert.notEqual(address, 0x0) // 비어있는 주소인지 체크 
            assert.notEqual(address, '')
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)

            // 주소가 'test'와 일치하는지? => 일치하지 않으므로 테스트 실패하고 에러뜸.
            // assert.equal(address, "test")
        })

        it('이름 유효성 검사', async () => {
            const contractName = await contract.name();
            assert.equal(contractName, name);
        })

        it('심볼 유효성 검사', async () => {
            const contractSymbol = await contract.symbol();
            assert.equal(contractSymbol, symbol);
        })
    })
})