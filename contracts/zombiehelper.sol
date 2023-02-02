pragma solidity ^0.4.19;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding  {

    modifier aboveLevel(uint _level, uint _zombieId) {

        // 좀비의 레벨이 입력 받은 레벨보다 높은지 확인
        require(zombies[_zombieId].level >= _level);
        _;
    }

    // 좀비의 레벨이 2 이상이면 이름 수정 가능
    function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) {
        require(zombieToOwner[_zombieId] == msg.sender);
        zombies[_zombieId].name = _newName;
    }

    // 좀비의 레벨이 20이상이면 좀비에게 임의의 dna 줄 수 있음
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
        require(zombieToOwner[_zombieId] == msg.sender);
        zombies[_zombieId].dna = _newDna;
    }

    // 사용자의 전체 좀비 군대를 반환
    function getZombiesByOwner(address _owner) external view returns(uint[]) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);

        uint counter = 0;
        for (uint i = 0; i < zombies.lengthl; i++) {
            if(zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

}