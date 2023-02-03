pragma solidity ^0.4.19;

import "./zombiehelper.sol";

contract ZombieBattle is ZombieHelper {
    uint randNonce = 0;  //난수를 만드는데 사용
    uint attackVictoryProbability = 70;  // 승리 확률

    // 난수 생성 후 반환 함수
    function randMod(uint _modulus) internal returns(uint) {
        randNonce++;  // 똑같은 입력으로 두 번 이상 동일한 해시 함수 실행할 수 없게하는 역할
        return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
    }

    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {

        Zombie storage myZombie = zombies[_zombieId];    // 내 좀비
        Zombie storage enemyZombie = zombies[_targetId]; // 상대 좀비

        uint rand = randMod(100);  // 값에 따라 전투 결과 결정

        // 내 좀비 승리
        if(rand <= attackVictoryProbability) {
            myZombie.winCount++;  
            myZombie.level++;
            enemyZombie.lossCount++;

            // 새로운 좀비 생성
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            // 내 좀비 패배
            myZombie.lossCount++;
            enemyZombie.winCount++;
        }

        // 좀비 쿨타임
        _triggerCooldown(myZombie);
    }
}