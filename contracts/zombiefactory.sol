pragma solidity ^0.4.19;

import "./ownable.sol";

// Ownable 상속
contract ZombieFactory is Ownable {

    // event 선언
    event NewZombie(uint zombieId , string name, uint dna);

    // dnaModulus라는 uint형 변수를 생성하고 10의 dnaDigits승을 배정
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    // 재사용 대기시간 : 1일이 지나야 다시 사용 가능
    uint cooldownTime = 1 days;

    // Zombie 라는 구조체 생성
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;  // 재사용 대기시간
    }

    // Zombie 구조체의 public 배열 생성
    Zombie[] public zombies;

    // 매핑 생성
    // 좀비 id로 좀비를 저장하고 검색
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    // 좀비 생성 private 함수 선언
    // 함수 접근 제어자를 private에서 internal로 변경
    function _createZombie(string _name, uint _dna) internal {

        // 새로운 좀비를 zombies 배열에 추가
        // 배열의 첫 원소가 0이라는 인덱스를 갖기 때문에, array.push() - 1은 막 추가된 좀비의 인덱스가 됨
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime))) - 1;

        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;

        // 새로운 좀비가 배열에 추가되면 이벤트 실행
        NewZombie(id, _name, _dna);
    }

    // uint를 반환하는 view 함수 선언
    function _generateRandomDna(string _str) private view returns (uint) {

        uint rand = uint(keccak256(_str));

        // 좀비 DNA가 16자리 숫자이기만을 원하므로 연산 후 값 반환
        return rand % dnaModulus;
    }

    // public 함수 선언
    function createRandomZombie(string _name) public {

        require(ownerZombieCount[msg.sender] == 0);
        // 좀비 dna 생성
        uint randDna = _generateRandomDna(_name);
        // 새로운 좀비 배열에 추가 
        _createZombie(_name, randDna);
    }

}