pragma solidity ^0.4.19;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding  {

    uint levelUpFee = 0.001 ether;

    modifier aboveLevel(uint _level, uint _zombieId) {
        // 좀비의 레벨이 입력 받은 레벨보다 높은지 확인
        require(zombies[_zombieId].level >= _level);
        _;
    }

    // 이더를 출금할 수 있는 함수
    function withdraw() external onlyOwner {
        // 컨트랙트에 저장되어 있는 전체 잔액을 특정 주소로 전달
        owner.transfer(this.balance);
    }

    // 이더 가격 변동을 대비해 소유자가 가격 변경 가능하게 하는 함수
    function levelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee; // 레벨업 이더 값 변경
    }

    // 이더를 받으면 좀비의 레벨을 올려주는 함수
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee); // 함수 실행에 이더가 보내졌는지 확인
        zombies[_zombieId].level = zombies[_zombieId].level.add(1); // 확인되면 좀비 레벨 증가
    }

    // 좀비의 레벨이 2 이상이면 이름 수정 가능
    function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }

    // 좀비의 레벨이 20이상이면 좀비에게 임의의 dna 줄 수 있음
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
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