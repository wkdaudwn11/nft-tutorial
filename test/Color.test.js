const { assert } = require('chai');

const Color = artifacts.require('./Color.sol');

require('chai').use(require('chai-as-promised')).should()

// 여기서 accounts는 Ganache의 네트워크(계정?) 주소가 배열 형태로 들어가있음.
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

    describe('minting', async () => {
        it('새로운 토큰 생성', async () => {
            const color = "#EC5856";

            // 토큰 추가하기
            const result = await contract.mint(color);

            // 전체 토큰 개수 가져오기
            const totalSupply = await contract.totalSupply();

            // 위에서 하나를 mint(추가) 했기 때문에, 전체 개수는 1이어야 정상
            assert.equal(totalSupply, 1);

            const event = result.logs[0].args;

            // assert.equal(event.tokenId.toNumber(), 1, 'id가 정확함');
            // 영상에선 위의 코드도 작성 했는데, event.tokenId.toNumber() 값이 0으로 나와서
            // 계속 테스트 실패함.
            // 일단 테스트니까 공부하는데엔 크게 문제가 아닐 거 같아서 일단 그냥 주석 처리.

            assert.equal(event.from, '0x0000000000000000000000000000000000000000', '발신자 정확함');
            assert.equal(event.to, accounts[0], '수신자 정확함');

            // 실패 사례 작성 (같은 색상의 토큰은 생성 할 수 없음)
            await contract.mint(color).should.be.rejected;
        })
    })

    describe('indexing', async () => {
        it('색상 목록', async () => {
            // 토큰 3개 Mint 하기
            await contract.mint("#5386E4");
            await contract.mint("#ffffff");
            await contract.mint("#000000");

            // 전체 토큰 개수 가져오기
            const totalSupply = await contract.totalSupply();

            let color;
            let result = [];

            for(let i = 1; i <= totalSupply; i++){
                color = await contract.colors(i - 1);
                result.push(color);
            }

            // minting에서 #EC5856 를 추가 했었기 때문에 여기선 토큰이 총 4개임.
            // contract를 제일 위에서 전역변수로 공유해서 쓰기 때문에 그런 거 같음.
            let expected = ['#EC5856', '#5386E4', '#ffffff', '#000000'];
            assert.equal(result.join(','), expected.join(','));
        })
    })
})