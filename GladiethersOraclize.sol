
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
pragma solidity ^0.4.20;

contract GladiethersOraclize is usingOraclize
{
    address public m_Owner;
    
    AbstractGladiethers m_Gladiethers = AbstractGladiethers(0x64127ab1de00337514f88382cefaddc786deb173);
    mapping (bytes32 => address) public queryIdToGladiator;
    mapping (bytes32 => bool) public queryIdToIsEthPrice;
    uint public gasprice = 10000000000;
    uint public eth_price = 500000;
    uint public totalGas = 169185;
    
    event random(string random);
    
    function GladiethersOraclize() public{
        m_Owner = msg.sender;
        oraclize_setCustomGasPrice(gasprice);
        oraclize_setProof(proofType_Ledger); // sets the Ledger authenticity proof in the constructor
    }
    
    function getOraclizePrice() public constant returns (uint) {
          return (totalGas*gasprice) +(5*1 ether)/eth_price;
    }
    

    function update(uint delay) payable {
        if (oraclize_getPrice("URL") > this.balance) {
        } else {
            bytes32 queryId = oraclize_query(delay, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
            queryIdToIsEthPrice[queryId] = true;
        }
    }
    
    function scheduleFight() public payable{
    
        require(now > 1527551940 && m_Gladiethers.getQueueLenght() > 1 && m_Gladiethers.getGladiatorPower(msg.sender) >= 10 finney); // to be changed with a real date
        uint callbackGas = totalGas; // amount of gas we want Oraclize to set for the callback function
        require(msg.value >= getOraclizePrice()); 
        uint N = 7; // number of random bytes we want the datasource to return
        uint delay = 0; // number of seconds to wait before the execution takes place
        bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas); // this function internally generates the correct oraclize_query and returns its queryId
        
        queryIdToGladiator[queryId] = msg.sender;
        m_Gladiethers.removeOrc(msg.sender);
        
        
    }
    
    
    // the callback function is called by Oraclize when the result is ready
    // the oraclize_randomDS_proofVerify modifier prevents an invalid proof to execute this function code:
    // the proof validity is fully verified on-chain
    function __callback(bytes32 _queryId, string _result, bytes _proof)
    {
     
      // if we reach this point successfully, it means that the attached authenticity proof has passed!
       if (msg.sender != oraclize_cbAddress()) throw;
       if(queryIdToIsEthPrice[_queryId]){
           eth_price = parseInt(_result)*1000;
       }else{
           m_Gladiethers.fight(queryIdToGladiator[_queryId],_result);
       }
       
       
    }

}
contract AbstractGladiethers
{
    function removeOrc(address gladiator) returns (bool);
    function fight(address gladiator1,string _result);
    function getQueueLenght() returns (uint);
    function getGladiatorPower(address gladiator) public view returns (uint);
}

