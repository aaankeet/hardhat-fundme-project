//SPDX-License-Identifier: MIT

//Pragma
pragma solidity ^0.8.8;

//imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

//errors
error FundMe__NotOwner();
error failed();

contract FundMe {
    address private immutable i_owner;
    // 790,612 gas - immutable

    using PriceConverter for uint256; //using library for uint25

    uint256 public constant minimumUSD = 50 * 1e18; // 5*10**18 ==  50000000000000000000

    // 832,883 gas non-constant
    // 813,587 gas constant

    AggregatorV3Interface private s_priceFeed;

    address[] private s_funders; // list of people who funded
    mapping(address => uint256) private s_addressToAmountFunded; // to track users how much they funded

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "You're Not the Owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // if someone sends ETH without calling fund function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUSD,
            "You Need to Spend More ETH"
        );
        s_addressToAmountFunded[msg.sender] = msg.value; // track amount funded by users
        s_funders.push(msg.sender); // funders added to the array
    }

    function withdrawFunds() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reseting the array
        s_funders = new address[](0);
        // acutal withdrawl of funds

        // Using transfer function to withdraw eth
        // payable(msg.sender).transfer(address(this).balance);

        // Using send function to withdwar eth
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,  "Send Failed");

        // call command to withdraw funds
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(sent, "Failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;

        for (
            uint256 fundersIndex;
            fundersIndex < s_funders.length;
            fundersIndex++
        ) {
            address funder = funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    function getFunders(uint256 index) public view returns (address) {
        return (s_funders[index]);
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }
}
