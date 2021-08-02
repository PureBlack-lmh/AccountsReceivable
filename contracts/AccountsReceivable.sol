// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.10;

// 简单的改过的token接口，模仿erc20
interface tokenRecipient { 
    function receiveApproval(string memory _from, uint256 _value, string memory _token, bytes memory _extraData) external; 
}
// 模仿erc20的一个合约，我称之为债卷
contract TokenERC20 {
    // 债卷名称
    string  name = "BaiduDebtVolume";
    // 债卷简称
    string  symbol  = "BDV";
    // 债卷小数点后几位
    uint8  decimals = 0;
    // 债卷总发布量
    uint256  totalSupply = 1*10**18;
    mapping (string => uint256)  balanceOf;  
    event Transfer(string indexed from, string indexed to, uint256 value);
    string public owner;

    //  输入需要查询的字符串，可查出该字符串下有多少债卷
    function balance(string memory perpor) public view returns(uint){
       return balanceOf[perpor];
    }
    
    // 用来进行债卷的转账的函数，私有不可以外部调用
    function transfer(string memory _from, string memory _to, uint _value) internal {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
}

contract  AccountsReceivable is TokenERC20 {

    // 上传账款结构体
    struct uploadAccount{
        string thisAccountName;         //该账款名称
        uint thisAccountMoney;          //该笔账款金额
        uint uploadTime ;               //上传时间
        address supplierAddress;        //供货商地址
        string accountsUrl;             //账款图片链接或视频链接
        bytes32 uniqueMark;             //唯一标示
        address enterpriseAddress;      //企业账号地址
        address bankAddress;            //银行账号地址
        bool accountIsNotPaid;          //是否已获得账款
        address ownerThisAccount;       //拥有这笔账款凭证的人
        bool isNotRepayment;            //是否已还款
        uint repaymentTime;             //还款日期
    }
    
    constructor(string memory _owner) public {
        owner = _owner;
        balanceOf[owner] = totalSupply;
    }

    //对uploadAccount进行映射，按accountsNumber的值可以找到该id下的账款的详细信息，在下面通过其他方法进行查看。
    mapping(uint=>uploadAccount) accountsId;
    // 账款总数
    uint public accountsNumber;
    
    // 该函数由供货商点击输入，输入要输入的该笔账款的名称，需要的金额，以及该账款的图片，视频等其他可以证明的链接
    // 该函数中默认值有该笔账款的供货商的地址，上传时间，唯一标记。
    function uploadAccounts(string memory _thisAccountName,uint _thisAccountMoney,string memory _accountsUrl) public {
        accountsNumber +=1 ;
        uploadAccount storage thisUploadAccount = accountsId[accountsNumber];
        thisUploadAccount.thisAccountName = _thisAccountName;
        thisUploadAccount.supplierAddress = msg.sender;
        thisUploadAccount.thisAccountMoney = _thisAccountMoney;
        thisUploadAccount.uploadTime = now;
        thisUploadAccount.accountsUrl = _accountsUrl;
        thisUploadAccount.ownerThisAccount = msg.sender;
        thisUploadAccount.uniqueMark= keccak256(abi.encodePacked
        (thisUploadAccount.thisAccountName,block.timestamp,thisUploadAccount.accountsUrl));
    }

    // 该函数由企业部门负责确认，先通过accountsId查询具体情况，然后输入该笔账款的ID进行点击，签上企业地址，来向别的环节证明。   
    function enterpriseConfirmation(uint AuditId)public{
        uploadAccount storage thisUploadAccount = accountsId[AuditId];
        thisUploadAccount.enterpriseAddress = msg.sender;
    }

    // 该函数由银行部门负责确认，先通过accountsId查询具体情况，然后输入该笔账款的ID进行点击，签上银行地址，来向别的环节证明。
    function bankConfirmation(uint AuditId)public{
        uploadAccount storage thisUploadAccount = accountsId[AuditId];
        thisUploadAccount.bankAddress = msg.sender;
    }

    // 该函数由金融机构负责确认，先通过accountsId查询具体情况，
    // 然后输入该笔账款的ID进行点击，签上金融机构地址，
    // 然后使用token里面的转账方法进行债卷的转移，并且将该笔账单拥有人转为金融机构。
    function confirmationOfFinancialInstitutions(uint AuditId)public{
        uploadAccount storage thisUploadAccount = accountsId[AuditId];
        thisUploadAccount.accountIsNotPaid = true;
        thisUploadAccount.ownerThisAccount = msg.sender;
        transfer(owner, thisUploadAccount.thisAccountName, thisUploadAccount.thisAccountMoney);
    }
    
    // 判断是否调用者为银行或公司
    modifier repaymentAuthority  () {
        uploadAccount storage thisUploadAccount = accountsId[accountsNumber];
        require(msg.sender == thisUploadAccount.bankAddress
        ||msg.sender == thisUploadAccount.enterpriseAddress );
        _;
    }

    //该函数是还款功能，只能由欠款企业进行调用进行还款，然后将债卷进行转移给owner，完成业务闭环
    function repayment(uint AuditId)repaymentAuthority public{
        uploadAccount storage thisUploadAccount = accountsId[AuditId];
        thisUploadAccount.ownerThisAccount = msg.sender;
        thisUploadAccount.isNotRepayment = true;
        thisUploadAccount.repaymentTime = now;
        transfer(thisUploadAccount.thisAccountName,owner,thisUploadAccount.thisAccountMoney);

    }

    // 该笔账款详情的查看
    function SeeAccountDetails(uint AuditId)public view returns(string memory,
    uint,uint,address,string memory,bytes32,address,address,bool,address,bool,uint){
        uploadAccount storage thisUploadAccount = accountsId[AuditId];
        return(thisUploadAccount.thisAccountName,thisUploadAccount.thisAccountMoney,
        thisUploadAccount.uploadTime,thisUploadAccount.supplierAddress,
        thisUploadAccount.accountsUrl,thisUploadAccount.uniqueMark,
        thisUploadAccount.enterpriseAddress,thisUploadAccount.bankAddress,
        thisUploadAccount.accountIsNotPaid,thisUploadAccount.ownerThisAccount,
        thisUploadAccount.isNotRepayment,thisUploadAccount.repaymentTime);
    }  
    
}