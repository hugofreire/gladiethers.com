
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";
pragma solidity ^0.4.20;

contract GladiethersOraclize is usingOraclize
{
    address public m_Owner;
    
    AbstractGladiethers m_Gladiethers = AbstractGladiethers(0x7c02b5b2801eb6184a4a741196b72871f141f702);
    mapping (bytes32 => address) public queryIdToGladiator;
    uint gasprice = 10000000000;
    uint eth_price = 660000;
    
    function GladiethersOraclize() public{
        m_Owner = msg.sender;
        oraclize_setCustomGasPrice(gasprice);
    }
    
    function setGasPrice(uint _gasprice, uint _eth_price) public{
      oraclize_setCustomGasPrice(_gasprice);
      eth_price = (_eth_price*1000);
    }
    
    function getOraclizePrice() public constant returns (uint) {
          return (57185*gasprice) +(5*1 ether)/eth_price;
    }
    
    function scheduleFight() public payable{
    
        require(now < 5000000000000); // to be changed with a real date
        uint callbackGas = 107185; // amount of gas we want Oraclize to set for the callback function
        require(msg.value >= getOraclizePrice() ); 
        bytes32 queryId = oraclize_query("WolframAlpha", "random number between 0 and 100",callbackGas);
        queryIdToGladiator[queryId] = msg.sender;
        m_Gladiethers.remove(msg.sender);
        
    }
    
    
    // the callback function is called by Oraclize when the result is ready
    // the oraclize_randomDS_proofVerify modifier prevents an invalid proof to execute this function code:
    // the proof validity is fully verified on-chain
    function __callback(bytes32 _queryId, string _result, bytes _proof)
    {
     
      require (msg.sender == oraclize_cbAddress() );
      // if we reach this point successfully, it means that the attached authenticity proof has passed!
      m_Gladiethers.fight(queryIdToGladiator[_queryId],_result);
      
       
    }

}
contract AbstractGladiethers
{
    function remove(address gladiator);
    function fight(address gladiator1,string _result);
}

