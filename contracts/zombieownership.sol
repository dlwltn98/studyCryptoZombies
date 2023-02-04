pragma solidity ^0.4.19;

import "./zombieattack.sol";
import "./erc721.sol";

/// TODO: natspec에 맞도록 이 부분을 바꾸기
/// @title 좀비 소유권 전송을 관리하는 컨트랙트
/// @author leejisu
/// @dev OpenZeppelin의 ERC721 표준 초안 구현을 따른다
contract ZombieOwnership is ZombieAttack, ERC721 {

    mapping (uint => address) zombieApprovals;

    // _owner가 가진 좀비의 수를 반환
    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerZombieCount[_owner];
    }

    // ID가 _tokenId인 좀비를 가진 주소를 반환
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return zombieToOwner[_tokenId];
    }

    // 전송 함수
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);    // 받는 사람의 좀비 수 증가
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);  // 보내는 사람의 좀비 수 감소
        zombieToOwner[_tokenId] = _to;
         
        Transfer(_from, _to, _tokenId); // 전송
    }

    // 토큰을 보내는 사람이 함수 호출
    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);  
    }

    // 토큰을 받는 사람이 함수 호출
    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _to;
        Approval(msg.sender, _approved, _tokenId);
    }

    // msg.sender가 토큰을 가질 수 있도록 승인되었는지 확인 후 _transfer 호출
    function takeOwnership(uint256 _tokenId) public {
        require(zombieApprovals[_tokenId] == msg.sender); // 승인 확인

        address owner = ownerOf(_tokenId);  // 토큰을 소유한 사람의 주소 확인
        _transfer(owner, msg.sender, _tokenId); 
    }
}