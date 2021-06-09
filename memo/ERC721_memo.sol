// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "./IERC721.sol";
// import "./IERC721Receiver.sol";
// import "./extensions/IERC721Metadata.sol";
// import "../../utils/Address.sol";
// import "../../utils/Context.sol";
// import "../../utils/Strings.sol";
// import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 *
 * @dev https://eips.ethereum.org/EIPS/eip-721[ERC721] 메타 데이터 확장을 포함하지만
 * {ERC721Enumerable}로 별도로 제공되는 Enumerable 확장을 포함하지 않는 대체 불가능한 토큰 표준의 구현.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name 토큰 이름
    string private _name;

    // Token symbol 토큰 심볼(상징)
    string private _symbol;

    // Mapping from token ID to owner address
    // 토큰 ID에서 소유자 주소로 매핑
    mapping (uint256 => address) private _owners;

    // Mapping owner address to token count
    // 소유자 주소를 토큰 개수 매핑
    mapping (address => uint256) private _balances;

    // Mapping from token ID to approved address
    // 토큰 ID에서 승인 된 주소로 매핑
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    // 소유자에서 운영자 승인으로 매핑
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     * @dev 토큰 컬렉션에 `name`과`symbol`을 설정하여 계약을 초기화합니다.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     *
     * @dev {tokenURI} 계산을위한 기본 URI입니다. 
     * 기본적으로 비어 있으며 하위 계약에서 재정의 할 수 있습니다.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     *
     * @dev 토큰이 영원히 잠기는 것을 방지하기 위해 계약 수신자가 ERC721 프로토콜을 알고 있는지 먼저 확인하여
     * `tokenId` 토큰을`from`에서`to`로 안전하게 전송합니다.
     * 
     * `_data`는 추가 데이터이며 지정된 형식이 없으며`to` 호출로 전송됩니다.
     *
     * 이 내부 함수는 {safeTransferFrom}과 동일하며 예를 들어 다음과 같은 용도로 사용할 수 있습니다. 
     * 서명 기반과 같은 토큰 전송을 수행하는 대체 메커니즘을 구현합니다.
     *
     * 요구 사항
     *
     * - 'from'은 0 주소가 될 수 없습니다.
     * - 'to'는 0 주소가 될 수 없습니다.
     * - 'tokenId'토큰이 있어야하며 'from'이 소유해야합니다.
     * - 'to'가 스마트 계약을 의미하는 경우 안전한 전송시 호출되는 {IERC721Receiver-onERC721Received}를 구현해야합니다.
     *
     * {Transfer} 이벤트를 생성합니다.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     *
     * @dev`tokenId`의 존재 여부를 반환합니다.
     * 토큰은 소유자 또는 승인 된 계정에서 {approve} 또는 {setApprovalForAll}을 통해 관리 할 수 ​​있습니다.
     * 토큰은 발행 될 때 (`_mint`) 존재하기 시작하고, 소각되면 존재하지 않습니다 (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * @dev`spender`가`tokenId`를 관리 할 수 ​​있는지 여부를 반환합니다.
     * 요구사항:
     * - `tokenId`가 있어야 합니다.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     *
     * @dev 안전하게`tokenId`를 생성하고`to`로 전송합니다.
     * 요구사항:
     * - 'tokenId'가 없어야합니다.
     * - 'to'가 스마트 계약을 의미하는 경우 안전한 전송시 호출되는 {IERC721Receiver-onERC721Received}를 구현해야합니다.
     *
     * {Transfer} 이벤트를 생성합니다.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     * 계약 수신자에게 {IERC721Receiver-onERC721Received}에서 전달되는 
     * 추가`data` 매개 변수가있는 {xref-ERC721-_safeMint-address-uint256-} [`_safeMint`]와 동일합니다.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     *
     * @dev 'tokenId'를 민트하고 'to'로 전송합니다.
     * 경고: 이 방법의 사용은 권장되지 않습니다. 가능하면 {_safeMint}를 사용하십시오.
     *
     * 요구사항:
     * -`tokenId`가 없어야합니다.
     * - 'to'는 제로 주소가 될 수 없습니다.
     *
     * {Transfer} 이벤트를 생성합니다.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     *
     * @dev`tokenId`를 파괴합니다.
     * 토큰이 소각되면 승인이 해제됩니다.
     *
     * 요구사항: 
     * - 'tokenId'가 있어야합니다.
     *
     * {Transfer} 이벤트를 생성합니다.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     *
     * @dev 'tokenId'를 'from'에서 'to'로 전송합니다.
     * {transferFrom}과 달리 msg.sender에 제한이 없습니다.
     *
     * 요구사항:
     * - 'to'는 제로 주소가 될 수 없습니다.
     * - `tokenId` 토큰은`from`이 소유해야합니다.
     *
     * {Transfer} 이벤트를 생성합니다.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        // 이전 소유자의 명확한 승인
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     *
     * @dev`tokenId`에서 작동하도록`to` 승인
     * {Transfer} 이벤트를 생성합니다.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     *
     * @dev 대상 주소에서 {IERC721Receiver-onERC721Received}를 호출하는 내부 함수입니다.
     * 대상 주소가 계약이 아닌 경우 호출이 실행되지 않습니다.
     *
     * @param from 주어진 토큰 ID의 이전 소유자를 나타내는 주소
     * @param to 토큰을받을 대상 주소
     * @param tokenId 전송할 토큰의 uint256 ID
     * @param _data 호출과 함께 보낼 바이트 선택적 데이터
     * @return bool 호출이 예상되는 매직 값을 올바르게 반환했는지 여부
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     *
     * @dev 토큰 전송 전에 호출되는 후크. 여기에는 채굴과 소각이 포함됩니다.
     *
     * 호출 조건 :
     * - 'from'과 'to'가 모두 0이 아닌 경우``from ''의 'tokenId'가 'to'로 전송됩니다.
     * - 'from'이 0이면 'tokenId'가 'to'에 대해 발행됩니다.
     * - 'to'가 0이면``from ''의 'tokenId'가 소각됩니다.
     * - 'from'은 0 주소가 될 수 없습니다.
     * - 'to'는 0 주소가 될 수 없습니다.
     *
     * 후크에 대해 자세히 알아 보려면 xref : ROOT : extending-contracts.adoc # using-hooks [Using Hooks]로 이동하세요.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}
