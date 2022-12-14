// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './FRT.sol';

contract FruitShop is FRT{
    // 과일종류
    string[] fruitInitList;
    // FRT Token 초기 설정
    address public owner;
    // 1이더당 200개
    uint public ethCanBuy = 200;
    constructor(string memory _name, string memory _symbol, uint _amount,uint _carrot, uint _apple, uint _lemon, uint _initPrice){
        // 토큰  초기셋팅
        owner = msg.sender;
        name = _name;
        symbol = _symbol;

        _initPrice *= 10**18;
        // 과일 초기 셋팅
        fruitInit["carrot"].num = _carrot;
        fruitInit["apple-whole"].num = _apple;
        fruitInit["lemon"].num = _lemon;
        fruitInit["carrot"].price = _initPrice * 3;
        fruitInit["apple-whole"].price = _initPrice;
        fruitInit["lemon"].price = _initPrice * 2;
        fruitInitList.push("carrot");
        fruitInitList.push("lemon");
        fruitInitList.push("apple-whole");
        mint(_amount * (10 ** uint(decimals)));
    }

    //과일 종류 get
    function getFruitInitList() view public returns(string[] memory){
        return fruitInitList;
    }
    // 이더를 frt로 교환해주기
    // CA로 Eth 보내는 경우
    receive() external payable{
        require(msg.value != 0);
        uint _amount = msg.value * ethCanBuy;

        require(balances[owner] >= _amount);
        balances[owner] -= _amount;
        balances[msg.sender] += _amount;

        if(msg.sender == owner){
            mint(_amount);
        }
    }
    // 홈페이지에서 토큰 교체
    // ETH => FRT
    function transferEthToFrt () payable public{
        require(msg.value != 0);
        uint _maxCan = msg.value * ethCanBuy ;
        require(balances[owner] >= _maxCan);

        balances[owner] -= _maxCan;
        balances[msg.sender] += _maxCan;
    }

    // FRT => ETH
    function transferFrtToEth (uint _amount) payable public{
        require(_amount != 0);
        _amount *=  10**decimals;

        balances[owner] += _amount;
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount /200);
    }

    // 과일 초기 100개씩 들어있음
    struct FruitInfo{
        uint num;
        uint price;
    }
    mapping (string=>FruitInfo) fruitInit;
    // 상점 과일 조회
    function getFruitShop(string memory _name)view public returns(FruitInfo memory){
        return fruitInit[_name];
    }
    // 상점에서 ETH로 과일 구매
    function buyFruitsByETH(string memory _name, uint _amount) public payable returns(uint){
        require(fruitInit[_name].num >= _amount);
        fruitInit[_name].num -= _amount;
        bool check = false;
        for(uint i = 0 ; i<hasFruitList[msg.sender].length; i++){
            if(keccak256(abi.encode(hasFruitList[msg.sender][i]))==keccak256(abi.encode(_name))){
                check = true;
            }
        }
        if(check){
            fruitWallet[msg.sender].num[_name] += _amount;
        }else{
            hasFruitList[msg.sender].push(_name);
            fruitWallet[msg.sender].num[_name] = _amount;
        }
        emit TransferETH(msg.sender,address(0),_name, _amount, msg.value/(10**18),block.timestamp,"ETH");
        return fruitWallet[msg.sender].num[_name];
    }
    // 상점에서 FRT로 과일구매 
    function buyFruitsByFRT(string memory _name, uint _amount) public payable returns(uint){
        require(fruitInit[_name].num >= _amount);
        balances[msg.sender] -= _amount * fruitInit[_name].price * ethCanBuy;
        fruitInit[_name].num -= _amount;
        bool check = false;
        for(uint i = 0 ; i<hasFruitList[msg.sender].length; i++){
            if(keccak256(abi.encode(hasFruitList[msg.sender][i]))==keccak256(abi.encode(_name))){
                check = true;
            }
        }
        if(check){
            fruitWallet[msg.sender].num[_name] += _amount;
        }else{
            hasFruitList[msg.sender].push(_name);
            fruitWallet[msg.sender].num[_name] = _amount;
        }
        emit TransferFRT(msg.sender,address(0),_name, _amount, _amount * fruitInit[_name].price * ethCanBuy /(10**18) ,block.timestamp,"FRT");
        return fruitWallet[msg.sender].num[_name];
    }
    // 초기 과일

    // 주소 -> 과일 -> 수량, 가격
    // 과일리스트
    mapping(string=>address[]) fruitTrader;
    function getFruitTrader(string memory _typeIs)view public returns(address[] memory){
        return fruitTrader[_typeIs];
    }
    // 판매자 매핑
    // {과일 : 과일주인,가격,수량}
    struct SellFruit{
        address owner;
        string name;
        uint price;
        uint num;
        string typeIs;
        string status;
        uint date;
        string unit;
    }
    mapping (string=>mapping(string=>mapping(string=>mapping(address=>SellFruit)))) makeShop;
    // 판매 등록
    function registerFruit(string memory _name,uint _price, uint _num,string memory _typeIs, string memory _unit) public payable {
        require(_num >0);
        if(keccak256(abi.encode(_typeIs))==keccak256(abi.encode("SELL"))){
            require(fruitWallet[msg.sender].num[_name] >= _num);
            fruitWallet[msg.sender].num[_name] -= _num;
        }else{
            if(keccak256(abi.encode(_unit))==keccak256(abi.encode("FRT"))){
                balances[msg.sender] -= _price * _num * 10 ** 18;
            }
        }
        require(keccak256(abi.encode(makeShop[_name][_typeIs][_unit][msg.sender].status)) != keccak256(abi.encode("on")));
        bool check = true;
        for(uint i = 0; i<fruitTrader[_typeIs].length; i++){
            if(fruitTrader[_typeIs][i] == msg.sender){
                check = false;
            }
        }
        
        if(check) fruitTrader[_typeIs].push(payable(msg.sender));
        makeShop[_name][_typeIs][_unit][msg.sender].owner = msg.sender;
        makeShop[_name][_typeIs][_unit][msg.sender].price = _price * 10 ** 18;
        makeShop[_name][_typeIs][_unit][msg.sender].num = _num;
        makeShop[_name][_typeIs][_unit][msg.sender].name = _name;
        makeShop[_name][_typeIs][_unit][msg.sender].typeIs = _typeIs;
        makeShop[_name][_typeIs][_unit][msg.sender].status = "on";
        makeShop[_name][_typeIs][_unit][msg.sender].date = block.timestamp;
        makeShop[_name][_typeIs][_unit][msg.sender].unit = _unit;
    }
    // 판매 삭제
    function deleteFruit(string memory _name,string memory _typeIs,string memory _unit) public payable{
        makeShop[_name][_typeIs][_unit][msg.sender].status = "off";
        if(keccak256(abi.encode(_typeIs))==keccak256(abi.encode("BUY"))){
            refund(_name, _typeIs,_unit);
        }
        fruitWallet[msg.sender].num[_name] += makeShop[_name][_typeIs][_unit][msg.sender].num;
    }
    // 먼저 돈낸거 환불받는곳
    function refund(string memory _name,string memory _typeIs, string memory _unit) public payable {
            uint refundMoney = makeShop[_name][_typeIs][_unit][msg.sender].price * makeShop[_name][_typeIs][_unit][msg.sender].num;
            payable(msg.sender).transfer(refundMoney);
    }
    // 과일 지갑
    // {주소 : {과일 종류 : 갯수}}
    struct Fruit{
        mapping(string=>uint) num;
    }
    mapping (address=>Fruit) fruitWallet;
    mapping (address=>string[]) hasFruitList;
    //과일 지갑 갯수 조회
    function getFruitWallet() view public returns(uint[] memory){
        uint count = hasFruitList[msg.sender].length;
        uint[] memory wallet = new uint[](count);
        for(uint i=0; i<count;i++){
            wallet[i] = fruitWallet[msg.sender].num[hasFruitList[msg.sender][i]];
        }
        return wallet;
    }
    // 과일 종류 조회
    function hasFruit() view public returns(string[] memory){
        return hasFruitList[msg.sender];
    }
    // 유저가 과일 구매
    function buyFruit(string memory _name, uint _num, string memory _typeIs, address _seller, string memory _unit) public payable {
        bool check = false;
        for(uint i = 0 ; i<hasFruitList[msg.sender].length; i++){
            if(keccak256(abi.encode(hasFruitList[msg.sender][i]))==keccak256(abi.encode(_name))){
                check = true;
            }
        }
        if(check){
            fruitWallet[msg.sender].num[_name] += _num;
        }else{
            hasFruitList[msg.sender].push(_name);
            fruitWallet[msg.sender].num[_name] = _num;
        }
        makeShop[_name][_typeIs][_unit][_seller].num -= _num;
        uint _amount = makeShop[_name][_typeIs][_unit][_seller].price * _num;
        uint sendMoney = _amount * 95 / 100;
        if(keccak256(abi.encode(_unit))==keccak256(abi.encode("ETH"))){
            payable(makeShop[_name][_typeIs][_unit][_seller].owner).transfer(sendMoney);
            emit TransferETH(msg.sender,_seller,_name, _num, _amount/(10**18), block.timestamp,"ETH");
        }else{
            balances[msg.sender] -= _amount;
            balances[_seller] += sendMoney;
             emit TransferFRT(msg.sender,_seller,_name, _num, _amount/(10**18), block.timestamp,"FRT");
        }
        
        
    }
    // 유저가 과일 판매
    function sellFruit(string memory _name, uint _num,string memory _typeIs,address _seller, string memory _unit) public payable {
        makeShop[_name][_typeIs][_unit][_seller].num -= _num;
        fruitWallet[_seller].num[_name] += _num;
        fruitWallet[msg.sender].num[_name] -= _num;
        uint _amount =  makeShop[_name][_typeIs][_unit][_seller].price * _num;
        uint sendMoney = _amount * 95 / 100;
        if(keccak256(abi.encode(_unit))==keccak256(abi.encode("ETH"))){
            payable(msg.sender).transfer(sendMoney);
            emit TransferETH(_seller,msg.sender,_name, _num, _amount/(10**18) , block.timestamp, "ETH");
        }else{ 
            balances[msg.sender] += sendMoney;
            emit TransferFRT(msg.sender,_seller,_name, _num, _amount/(10**18), block.timestamp,"FRT");
        }
    }
    // 물건 조회
    function getSellerListETH(string memory _name, string memory _typeIs,address _seller) public view returns(SellFruit memory){
        return makeShop[_name][_typeIs]["ETH"][_seller];
    }
    function getSellerListFRT(string memory _name, string memory _typeIs,address _seller) public view returns(SellFruit memory){
        return makeShop[_name][_typeIs]["FRT"][_seller];
    }


    // 구매자 판매자 물건이름 수량 총가격
    event TransferETH(address from, address to, string name, uint num, uint value, uint date, string pay);
    event TransferFRT(address from, address to, string name, uint num, uint value, uint date, string pay);
}