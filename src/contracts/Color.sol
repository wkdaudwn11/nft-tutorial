pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Color is ERC721 { 
    // constructor는 스마트 컨트랙트가 배포 될 때마다 실행되는 함수 (기본적인 생성자 함수 기능과 같은듯)
    constructor() ERC721("Color", "COLOR") {}
}