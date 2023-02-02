pragma solidity ^0.4.19;

// zombiefactory.sol 불러오기
import "./zombiefactory.sol";

// KittyInterface라는 인터페이스를 정의
contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

// ZombieFactory 상속
contract ZombieFeeding is ZombieFactory {

    // 크립토키티 컨트랙트 주소의 업데이트가 가능하도록 수정
    KittyInterface kittyContract;
    // 소유자만 수정할 수 있도록 수정
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // 1일을 초단위로 바꾼것의 합과 같음
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    // 좀비가 먹이를 먹은 후 충분한 시간이 지났는지 판단해서 알려줌
    function _isReady(Zombie storage _zombie) internal view returns(bool) {
        return (_zombie.readyTime <= now);
    }

    // 좀비 dna가 생명체의 dna와 혼합되어 새로운 좀비 생성
    function feedAndMultiply(uint _zombieId, uint _targetDna) internal {
        
        // 주인만 좀비에게 먹이를 줄 수 있음
        require(msg.sender == zombieToOwner[_zombieId]);

        // 먹이를 먹는 좀비의 dna 얻음
        Zombie storage myZombie = zombies[_zombieId];

       // 좀비가 먹이 먹은 시간을 고려하도록 수정
       require(_isReady(myZombie));

        _targetDna = _targetDna % dnaModulus; // 16자리보다 크면 안됨
        uint newDna = (myZombie + _targetDna) / 2;  // 새로운 dna 

        // 키티 유전자를 가진 좀비는 dna 마지막 2자리를 99로 변경
        if(keccak256(_species) == keccak256("kitty")) {
            newDna = newDna - newDna % 100 + 99;
        }

       // 좀비 생성 함수 호출
       // 인자로 좀비의 이름과 dna 값을 받음
        _createZombie("NoName", newDna);

        // 좀비의 재사용 대기시간 만듦
        _triggerCooldown(myZombie);
    }

    // 크립토키티 컨트랙트와 상호작용
    // 크립토키티 컨트랙트에서 고양이 유전자를 얻어내는 함수를 생성
    function feedOnKitty (uint _zombieId, uint _kittyId, string _species) public {

        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);

        // dna가 혼합된 새로운 좀비를 생성하는 함수
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }

}