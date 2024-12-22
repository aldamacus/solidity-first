// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultCoin is ERC20, Ownable {

uint256 private initialSupply = 100000000 * 10**decimals();
uint256 public  maxTxAmount = initialSupply;
uint256 public  cooldownTime = 1 minutes;
uint256 public  taxFees = 5;
uint256 public  slippageFees = 2;

bool private _whiteListingEnabled= false;
bool private _taxEnabled= false;

address public taxAddress;

bool private _blackListingEnabled = false;

mapping(address=>bool) private _blackList;
mapping(address=>bool) private _taxList;
mapping(address=>bool) private _whiteList;
mapping(address=>uint256) private _lastTxTime;

constructor(address initialOwner, address _taxAddress)
    ERC20("VaultCoin", "Vault")
    Ownable(initialOwner){
        _mint(initialOwner,initialSupply); // mint initial supply to the initial owner
        _whiteList[initialOwner] = true;
        taxAddress=_taxAddress;
    }
    
    
    function renounceOwnership() public override onlyOwner{
    
         //transferOwnership(address(0x000000000000000000000000000000000000dEaD));
       super.renounceOwnership();
    }

    function enableWhiteListing() external onlyOwner
    {
        _whiteListingEnabled=true;
    }

    function enableBlackListing() external onlyOwner
    {
        _blackListingEnabled=true;
    }
 
   function enableTax() external onlyOwner
    {
        _taxEnabled=true;
    }

    function disableTax() external onlyOwner
    {
        _taxEnabled=false;
    }
 

    function addToWhiteList(address account)     external onlyOwner 
        {
        
            require(!_blackList[account],"Blacklisted accounts cannot be whitelisted");
             _whiteList[account] = true;
          
        }
        
    function addToBlacklist(address account)     external onlyOwner 
        {
     
             _blackList[account] = true;
            
        }


 
    function removeFromBlacklist(address account)     external onlyOwner 
        {
           
             _blackList[account] = false;
        }
    
    function removeFromWhiteList(address account)     external onlyOwner 
        {
    
             _whiteList[account] = false;
        }


    function isBlacklisted(address account) external view returns (bool) 
        {
            return _blackList[account];
        }

    function isWhiteListed(address account) external view returns (bool) 
        {
            return _whiteList[account];
        }

        function setMaxTxAmount(uint256 newMaxTxAmount) external onlyOwner {
            maxTxAmount = newMaxTxAmount;
        //  emit MaximumTransferLimitUpdated(_maxTxAmount);
        
        }

        function getMaxTxAmount() external view returns(uint256){
            return maxTxAmount;
        
        }

        function getContractDetials() external view returns (address, uint256, uint256, uint256)
        {
            return (owner(),maxTxAmount,cooldownTime,initialSupply);
        }


        function setCooldownTime(uint256 newCooldownTime) external onlyOwner{
            cooldownTime=newCooldownTime;      
        }


    function _update(address from, address to, uint256 value) internal override {
        require(!_blackList[to] && !_blackList[from],"Blacklisted address");
        if(_whiteListingEnabled){
            require(_whiteList[from] && _whiteList[to], "Both addresses must be whitelisted");
        }
        require(value <= maxTxAmount,"Token transfer limit exceeded");
        require(block.timestamp >= _lastTxTime[from] +cooldownTime,"Cooldown time period");
        _lastTxTime[from] = block.timestamp;
    
        
        if(_taxList[from] || !_taxEnabled){
           // do nothing related to taxes. They are exempted
            super._update(from, to, value);
        }else if(_taxEnabled){ 
            uint256 totalFees = (value * (taxFees+slippageFees))/100 ; //Calculating taxes based on value and fees
            value =  value - totalFees;
            super._update(from, taxAddress, value);
        }        
    
    }

// ************************** Taxes and Slippage ************************************
    function setTaxes(uint256 newTaxFee) external onlyOwner{
        require(newTaxFee<=10, "Tax fee cannot be higher than 10%");
        taxFees=newTaxFee;
    }

    function getSlippageFees() external view returns (uint256){
        return slippageFees;
    }
    function getTaxes() external view returns (uint256){
        return taxFees;
    }

     function setSlippageFees(uint256 newSlippageFee) external onlyOwner{
        require(newSlippageFee<=5, "Slippage fees cannot be higher than 5%");
        slippageFees=newSlippageFee;
    }

    function addExemptionToTaxes(address account)     external onlyOwner {
             _taxList[account] = true;    
    }

    function removeExemptionFromTaxes(address account)     external onlyOwner{ 
             _taxList[account] = false;    
    }


}




