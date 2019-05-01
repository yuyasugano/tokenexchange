pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

contract TokenZendR is Ownable, Pausable {

  /**
   * @dev Details of each transfer
   * @param contract_ contract address of ER20 token to transfer
   * @param to_ receiving account
   * @param amount_ number of tokens to transfer to_ account
   * @param failed_ if transfer was successful or not
   */
  struct Transfer {
    address contract_;
    address to_;
    uint amount_;
    bool failed_;
  }

  /**
   * @dev a mapping from transaction ID's to the sender address
   * that initiates them. Owners can create several transactions
   */
  mapping(address => uint[]) public transactionIndexesToSender;

  /**
   * @dev a list of all transfers successful or unsuccessful
  */
  Transfer[] public transactions;
  address public owner;

  /**
   * @dev list of all supported tokens for transfer
   * @param string token symbol
   * @param address contract address of token
   */
  mapping(bytes32 => address) public tokens;

  ERC20 public ERC20Interface;

  /**
   * @dev Event to notify if transfer successful or failed
   * after account approval verified
   */
  event TransferSuccessful(address indexed _from, address indexed _to, uint256 _amount);
  event TransferFailed(address indexed _from, address indexed _to, uint256 _amount);

  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev add address of token to list of supported tokens using
   * token symbol as identifier in mapping
   */
  function addNewToken(bytes32 _symbol, address _address) public onlyOwner returns (bool) {
    tokens[_symbol] = _address;
    return true;
  }

  /**
   * @dev remove address of token we no more support
   */
  function removeToken(bytes32 _symbol) public onlyOwner returns (bool) {
    require(tokens[_symbol] != 0x0);
    delete(tokens[_symbol]);
    return true;
  }

  /**
   * @dev method that handles transfer of ERC20 tokens to other address
   * it assumes the calling address has approved this contract
   * as spender
   * @param _symbol identifier mapping to a token contract address
   * @param _to beneficiary address
   * @param _amount numbers of token to transfer
   */
  function transferTokens(bytes32 _symbol, address _to, uint256 _amount) public whenNotPaused {
    require(tokens[_symbol] != 0x0);
    require(_amount > 0);

    address _contract = tokens[_symbol];
    address _from = msg.sender;

    ERC20Interface = ERC20(_contract);

    uint256 transactionId = transactions.push(
      Transfer({
        contract_: _contract,
        to_: _to,
        amount_: _amount,
        failed_: true
      })
    );

    transactionIndexesToSender[_from].push(transactionId - 1);

    if(_amount > ERC20Interface.allowance(_from, address(this))) {
      emit TransferFailed(_from, _to, _amount);
      revert();
    }

    ERC20Interface.transferFrom(_from, _to, _amount);
    transactions[transactionId - 1].failed_ = false;
    emit TransferSuccessful(_from, _to, _amount);
  }

  /**
   * @dev allow contract to receive funds
   */
  function() public payable {}

  /**
   * @dev withdraw funds from this contract for the owner
   * @param beneficiary address to receive ether
   */
  function withdraw(address beneficiary) public payable onlyOwner whenNotPaused {
    beneficiary.transfer(address(this).balance);
  }
}


