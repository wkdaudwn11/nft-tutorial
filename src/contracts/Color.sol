pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "./ERC721.sol";
// pragma solidity >=0.5.16;
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// ERC721.sol 파일 생성 명령어
// ./node_modules/.bin/truffle-flattener ./node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol > src/contracts/ERC721.sol

contract Color is ERC721 { 

    // ERC721한테 name, symbol을 파라미터 값으로 줌
    // constructor() ERC721("Color", "COLOR") public {
    // }

    constructor() ERC721("Color", "COLOR") public {
    }

}