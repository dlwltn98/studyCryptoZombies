pragma solidity ^0.4.19;

contract ZombieFactory {

    // event 선언
    event NewZombie(uint zombieId , string name, uint dna);

    // dnaModulus라는 uint형 변수를 생성하고 10의 dnaDigits승을 배정
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    // Zombie 라는 구조체 생성
    struct Zombie {
        string name;
        uint dna;
    }

    // Zombie 구조체의 public 배열 생성
    Zombie[] public zombies;

    // 좀비 생성 private 함수 선언
    function _createZombie(string _name, uint _dna) private {

        // 새로운 좀비를 zombies 배열에 추가
        // 배열의 첫 원소가 0이라는 인덱스를 갖기 때문에, array.push() - 1은 막 추가된 좀비의 인덱스가 됨
        uint id = zombies.push(Zombie(_name, _dna)) - 1;

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
        // 좀비 dna 생성
        uint randDna = _generateRandomDna(_name);
        // 새로운 좀비 배열에 추가 
        _createZombie(_name, randDna);
    }

}