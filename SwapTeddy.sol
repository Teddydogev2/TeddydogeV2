// SPDX-License-Identifier: GCT
pragma solidity ^0.8.1;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    event Transfer(address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.8.1;
library Safe{
    function SafeCall(address target, bytes memory data) internal returns (bytes memory) {
         require(target.code.length > 0, "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value : 0}(data);
        return verifyCallResult(success, returndata, "Address: low-level call failed");
    }
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
pragma solidity ^0.8.1;
contract SwapTeddy{
    using Safe for address;
    bool public status=true;
    address public owner;
    address public teddyV1;
    address public teddyV2;
    constructor(address _v1,address _v2){
        owner=_msgSender();
        setAddress(_v1,_v2);
    }
    function _msgSender() internal view returns(address){
        return msg.sender;
    }
    modifier onlyOwner{
        require(_msgSender()==owner,"not is owner");
        _;
    }
    function setStatus(bool _status) public onlyOwner{
       status=_status;
    }
    function setAddress(address _v1,address _v2) public onlyOwner{
        teddyV1=_v1;
        teddyV2=_v2;
    }
    function burnV2() public onlyOwner{
        IERC20 addr=IERC20(teddyV2);
        uint256 amount=addr.balanceOf(address(this));
        require(amount>0,"balance is 0");
        status=false;
        teddyV2.SafeCall(abi.encodeWithSelector(
            addr.burn.selector,
            amount
        ));
    }
    function swap(uint256 amount) public virtual{
        require(status,"swap is end");
        require(amount>0,"swap amount must be more then 0");
        address from=_msgSender();
        teddyV1.SafeCall(
            abi.encodeWithSelector(
                IERC20(teddyV1).transferFrom.selector,
                from,address(this),
                amount
            )
        );
         teddyV2.SafeCall(
             abi.encodeWithSelector(
                 IERC20(teddyV2).transfer.selector,
                 from,
                 amount
            )
        );
    }
     function withdrawV2() public onlyOwner{
        IERC20 addr=IERC20(teddyV2);
        uint256 amount=addr.balanceOf(address(this));
        require(amount>0,"balance is 0");
        teddyV2.SafeCall(abi.encodeWithSelector(
            addr.transfer.selector,
            _msgSender(),
            amount
        ));
    }
}