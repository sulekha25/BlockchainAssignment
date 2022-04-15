// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "hardhat/console.sol";

//***********************************No intermediary*******************************************//
//...................................Proprty Transfer..........................................//
//.......................A decentralized method to transfer the property.......................//


//***********************************Benifits**************************************************//
//1. No central authority.
//2. less time consuming.
//3. less expenses.
//4. No document management burden.
//5. No possible fraudulents.

//................................smart contract begins........................................//

contract PropertyTransfer {


    address private owner;	

    uint256 public totalNoOfProperty;	
    
    constructor() {
        console.log("Owner contract deployed by:", msg.sender);
        owner = msg.sender; // only owner can transfer the property, 'msg.sender' is sender of current call, contract deployer for a constructor
        totalNoOfProperty = 0;
        emit OwnerSet(address(0), owner);
    }

    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

// Property Details

    struct PropertyDetails {
		string p_name;                 
		string p_street;                        
		string p_city;
		string p_state;
		string p_zip;
		string p_country;
        uint256 propertyCount;
        bool isSold;
    }					

//property mapping with owner					
    mapping(address => mapping(uint256=>PropertyDetails)) public propertyowner; 
																		
    mapping(address => uint256) propertyCountPerOwner;	// per owner property count regards to individual	

// events for property alloted and Property Transferred

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    event PropertyAlloted(address indexed _verifiedOwner, uint256 indexed  _totalNoOfPropertyCurrently, string _nameOfProperty, string _msg);

    event PropertyTransferred(address indexed _from, address indexed _to, string _propertyName, string _msg);

  
//******* per address property count*******//  

    function getPropertyCountOfAnyAddress(address _ownerAddress) public view returns (uint256){
        uint count=0;
        for(uint i =0; i<propertyCountPerOwner[_ownerAddress];i++){
            if(propertyowner[_ownerAddress][i].isSold != true)
            count++;
        }
        return count;
    }

//******** Property allocation to the new owner with a verification first**********//

    function allotProperty(address _verifiedOwner, string memory _propertyName) public onlyOwner {
        propertyowner[_verifiedOwner][propertyCountPerOwner[_verifiedOwner]++].p_name = _propertyName;
        totalNoOfProperty++;
        emit PropertyAlloted(_verifiedOwner,propertyCountPerOwner[_verifiedOwner], _propertyName, "property allotted successfully");
    }

// ************ check the owner of the property using property name as unique name and by putting address to check*********//    

    function isOwner(address _checkOwnerAddress, string memory _propertyName) public view returns (uint){
        uint i ;
        bool flag ;
        for(i=0 ; i<propertyCountPerOwner[_checkOwnerAddress]; i++){
            if(propertyowner[_checkOwnerAddress][i].isSold == true){
                break;
            }
         flag = stringsEqual(propertyowner[_checkOwnerAddress][i].p_name,_propertyName);
            if(flag == true){
                break;
            }
        }
        if(flag == true){
            return i;
        }
        else {
            return 999999999;
        }
    }

   
    function stringsEqual(string memory a1, string memory a2) private pure returns (bool) {
        if(sha256(abi.encodePacked(a1)) == sha256(abi.encodePacked(a2)))
            return true;
        else
            return false;
    }

   
//********************** transfer of property **********************************//
//**********************this should be called by the verification only**********//


    function transferProperty (address _to, string memory _propertyName) public returns (bool ,  uint )
    {
        uint256 checkOwner = isOwner(msg.sender, _propertyName);
        bool flag;

        if(checkOwner != 999999999 && propertyowner[msg.sender][checkOwner].isSold == false){
            
            propertyowner[msg.sender][checkOwner].isSold = true;
            propertyowner[msg.sender][checkOwner].p_name = "Sold";
            propertyowner[_to][propertyCountPerOwner[_to]++].p_name = _propertyName;
            flag = true;
            emit OwnerSet(msg.sender, _to);
            emit PropertyTransferred(msg.sender , _to, _propertyName, "Owner has been changed." );
        }
        else {
            flag = false;
            emit PropertyTransferred(msg.sender , _to, _propertyName, " doesn't own the property." );
        }
        return (flag, checkOwner);
    }
}

//................................smart contract ends..........................................//
