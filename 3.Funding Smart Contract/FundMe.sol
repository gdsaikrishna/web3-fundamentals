// SPDX-License-Identifier: MIT

// Smart Contract to deposit ETH into the contract and withdrawal is only possible by owner
pragma solidity >=0.6.0 <0.9.0;

//Latest ETH/USD price from Chainlink Oracle price feed
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// No need for SafeMath if solidity version >= 0.8.0
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    // safe math library check uint256 for integer overflows
    using SafeMathChainlink for uint256;

    //mapping to store Address => Deposited ETH
    mapping(address => uint256) public addressToAmountFunded;
    //list of addresses who deposited
    address[] public funders;
    //address of the owner (who deployed the contract)
    address public owner;

    //owner - Address which deployed the contract
    constructor() public {
        owner = msg.sender;
    }

    //function to deposit ETH to funding
    function fund() public payable{
        // 18 digit number to be compared with donated amount of minimum 50USD
        uint256 minUSD = 50*10**18;
        require(getConversionRate(msg.value) >= minUSD, "You need to spend more ETH") ;
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    //function to get the version of the chainlink pricefeed
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    //Function to get price using Chainlink pricefeed
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        // PriceFeed don't have decimals, get value by mul 10^-8
        // ETH/USD rate in 18 digit (mul 10^10 to convert to 18 digit)
        return uint256(answer * 10000000000);
    }

    //function to get USD with given ETH
    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // the actual ETH/USD conversation rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    //modifier to verify the owner
    modifier onlyOnwer {
        require(msg.sender == owner);
        _;
    }

    //Withdraw with onlyOwner condition
    function withdraw() payable onlyOwner public {
        // If you are using version eight (v0.8) of chainlink aggregator interface,
	    // Use the below commented code
	    // payable(msg.sender).transfer(address(this).balance);
        msg.sender.transfer(address(this).balance);

        //iterate through all the mappings and make them 0
        //since all the deposited amount has been withdrawn
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //funders array will be initialized to 0
        funders = new address[](0);

    }
} 