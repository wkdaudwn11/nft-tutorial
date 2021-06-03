pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// totalSupply 라는 함수는 ERC721에는 없고 ERC721Enumerable 파일에 있음.
// 그래서 ERC721Enumerable도 새로 추가해줌.
contract Color is ERC721, ERC721Enumerable { 
    string[] public colors;

    // string 타입의 color를 받으면 이미 존재하는지에 대한 boolean 값을 리턴
    mapping(string => bool) _colorExists;

    // constructor는 스마트 컨트랙트가 배포 될 때마다 실행되는 함수 (기본적인 생성자 함수 기능과 같은듯)
    constructor() ERC721("Color", "COLOR") {}

    // ERC721, ERC721Enumerable 파일에서 _beforeTokenTransfer(), supportsInterface()가
    // 서로 겹치기 때문에 그거 해결해주는 코드 같음
    // 함수명 겹친 거 해결 시작
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    // 함수명 겹친 거 해결 끝

    // 새로운 토큰을 생성하는 함수 (이를 보통 mint 라고 부름)
    // 토큰(코인)을 생성한다 === 채굴한다.
    function mint(string memory _color) public{ 
        // 컬러가 이미 존재하는지 체크
        // require 함수는 true일 경우엔 아무 일도 일어나지 않고,
        // false 일 경우엔 예외(Exception)가 발생하여 다음 코드를 실행하지 않는다.
        // if문 같은 걸로 예외처리 하는 것임.
        require(!_colorExists[_color]);

        // 새로운 컬러이므로 push한 후 id값 생성
        colors.push(_color);
        uint256 _id = colors.length - 1; // 마지막 인덱스 값

        // openZeppelin의 ERC721 안에 있는 _mint 함수 호출 (msg.sender는 받는 사람의 주소?)
        _mint(msg.sender, _id);

        // _colorExists에다가 _color를 true로 해줘야 다음에 유효성검사에 같은 color가 왔을 떄 걸림.
        _colorExists[_color] = true;
    }
}