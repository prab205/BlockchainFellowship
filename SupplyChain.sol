pragma solidity ^0.5.0;

contract SupplyChain {

  address owner;
  uint public skuCount;

    enum State{ ForSale, Sold, Shipped, Received }

    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }

    mapping(uint => Item) public items;

    event LogForSale(uint);
    event LogSold(uint);
    event LogShipped(uint);
    event LogReceived(uint);

    modifier isOwner() {
        require (msg.sender == owner, "You are not the owner");
        _;
    }

  modifier verifyCaller (address _address) { require (msg.sender == _address); _;}

  modifier paidEnough(uint _price) { require(msg.value >= _price); _;}

  modifier checkValue(uint _sku) {
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }

  modifier forSale(uint _sku) {
      Item memory temp = items[_sku];
      require (bytes(temp.name).length > 0, "The item is not initialized");
      require (temp.state == State.ForSale, "The item is not for sale");
      _;
  }
  modifier sold(uint _sku) {
      require (items[_sku].state == State.Sold, "The item is not sold");
      _;
  }
  modifier shipped(uint _sku) {
      require (items[_sku].state == State.Shipped, "The item is not shipped");
      _;
  }
  modifier received(uint _sku) {
      require (items[_sku].state == State.Received, "The item is not received");
      _;
  }

  constructor() public {
      owner = msg.sender;
      skuCount = 0;
  }

  function addItem(string memory _name, uint _price) public returns(bool){
    emit LogForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount + 1;
    return true;
  }

  function buyItem (uint sku) public payable forSale(sku) paidEnough(items[sku].price) checkValue(sku) {
      items[sku].buyer = msg.sender;
      items[sku].state = State.Sold;
      emit LogSold(sku);
  }

  function shipItem(uint sku) public sold(sku) verifyCaller(items[sku].seller) {
      items[sku].state = State.Shipped;
      emit LogShipped(sku);
  }

  function receiveItem(uint sku) public shipped(sku) verifyCaller(items[sku].buyer) {
      items[sku].state = State.Received;
  }

  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }
}