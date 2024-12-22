// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultCoin is ERC20, Ownable {

uint256 private initialSupply = 100000000 * 10**decimals();
mapping(address=>bool) private _blackList;
constructor(address initialOwner)
    ERC20("VaultCoin", "Vault")
    Ownable(initialOwner){
        _mint(initialOwner,initialSupply); // mint initial supply to the initial owner
    }
    
    
    function renounceOwnership() public override onlyOwner{
    
         //transferOwnership(address(0x000000000000000000000000000000000000dEaD));
         super.renounceOwnership();
    }

    function addToBlacklist(address account)     external onlyOwner 
        {
             _blackList[account] = true;
        }

         function removeFromBlacklist(address account)     external onlyOwner 
        {
             _blackList[account] = false;
        }

    function isBlacklisted(address account) external view returns (bool) 
        {
            return _blackList[account];
        }

    function _update(address from, address to, uint256 value) internal override {
    
        require(!_blackList[to] && !_blackList[from],"Blacklisted address");
        super._update(from, to, value);
    }

}