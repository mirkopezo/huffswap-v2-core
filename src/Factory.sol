// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Ownable} from "solady/auth/Ownable.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {CREATE3} from "solady/utils/CREATE3.sol";

/**
 * @author taken from https://github.com/LatamSwap/latamswap-dex
 */
contract HuffSwapFactory is Ownable {
    using SafeTransferLib for address;

    error ErrZeroAddress();
    error ErrIdenticalAddress();
    error ErrPairExists();
    error ErrNativoMustBeDeployed();

    /// @dev Maps tokens to its pair
    mapping(address fromToken => mapping(address toToken => address pair)) public getPair;
    /// @dev Stores all created pairs
    address[] public allPairs;

    /// @dev Event emitted when a new pair is created
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256 allPairsLength);

    /// @dev Initializes the owner of the contract
    constructor(address _owner) {
        _initializeOwner(_owner);
    }

    function getCreationCode(address token0, address token1) internal view returns (bytes memory r) {
        r = abi.encodePacked(
            hex"38600b3d39600b38033df33461200957343560e01c80630dfe1681146106e4578063d21220a7146106f7578063c45a01551461070a578063022c0d9f146101d55780636a6278421061010457806323b872dd106100ad578063095ea7b310610087578063095ea7b31461078a57806301ffc9a7146106b857806306fdde031461071d5780630902f1ac1461073a576101c8565b806323b872dd146108b15780631296ee62146107ce57806318160ddd14610893576101c8565b80634000aea0106100de578063313ce567146109725780633177029f1461097b5780634000aea0146107ce576101c8565b80636a62784214610a4c5780635909c0d514610a105780635a3d549314610a2e576101c8565b8063bc25cf771061017c57806389afcb441061014b57806389afcb44146112385780636a62784214610a4c57806370a082311461120f5780637464fc3d1461121a576101c8565b8063bc25cf77146119f057806395d89b4114611967578063a9059cbb14611980578063ba9a7a5614611fff576101c8565b8063d8fbe994106101ad578063c1d34b8914611bd6578063cae9ca511461097b578063d8fbe99414611bd6576101c8565b8063dd62ed3e14611cf1578063fff6cae914611d08576101c8565b63d5cf065534526004601cfd5b7401000000000000000000000000000000000000000260027401000000000000000000000000000000000000000554106102165763ab143c0634526004601cfd5b6002740100000000000000000000000000000000000000055554806dffffffffffffffffffffffffffff166024358060043573ffffffffffffffffffffffffffffffffffffffff604435168482108660701c6dffffffffffffffffffffffffffff16968286851761028e576342301c2334526004601cfd5b8060206040380360003960005114156102ae5763290fa18834526004601cfd5b60206020380360003960005114156102cd5763290fa18834526004601cfd5b60e01c948711176102e55763bb55fd2734526004601cfd5b828282602060403803600039600051821561033b5782828291906fa9059cbb00000000000000000000000034526014526034523460446010346020945af160013451141761033a576390b8ec1834526004601cfd5b5b5050508160206020380360003960005182156103925782828291906fa9059cbb00000000000000000000000034526014526034523460446010346020945af1600134511417610391576390b8ec1834526004601cfd5b5b505050608435156103de5782828291349160243360046084360360846084376310d1e85c60e01b34525252604452608060645236343434945af16103dd57637fd1918d34526004601cfd5b5b505050306020604038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa61042057633dd8248734526004601cfd5b3451306020602038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa61046157633dd8248734526004601cfd5b34519184848484929190936dffffffffffffffffffffffffffff85116dffffffffffffffffffffffffffff8511156104a0576335278d1234526004601cfd5b156104b2576335278d1234526004601cfd5b420363ffffffff168282821717156105c7577401000000000000000000000000000000000000000454818284866e010000000000000000000000000000027bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1602740100000000000000000000000000000000000000035401740100000000000000000000000000000000000000035584846e010000000000000000000000000000027bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16020174010000000000000000000000000000000000000004555b50505081819060701b4260e01b1717740100000000000000000000000000000000000000025534526020527f1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1604034a1620f42408184036000811160009182180218938386036000811160009182180218950202916103e80260038502600385029103916103e802030211610663576335b01a0f34526004601cfd5b3452602052604460043560405235337fd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822608060243560605234a360017401000000000000000000000000000000000000000555005b60043560e01c6336372b0781146301ffc9a782141781637d4c6ff5149163b0202a111417173452602034f35b6020604038036000396000513452602034f35b6020602038036000396000513452602034f35b6020606038036000396000513452602034f35b6f0f48756666537761702050616972563260203452602f52606034f35b74010000000000000000000000000000000000000002548060701c6dffffffffffffffffffffffffffff168160e01c916dffffffffffffffffffffffffffff166060838234528360205260405234f35b6020600134600435602435348183336020523452604034205552337f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925602034a35234f35b6020600173ffffffffffffffffffffffffffffffffffffffff6004351660243581338233549081039081111561080b5763f4d678b834526004601cfd5b3384604452557fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef60206044a38154018155346020346060360134346388a7ca5c60e01b965a608060643360048c6044360360446064373452523360245252f161087b576385b1639434526004601cfd5b511461088e576385b1639434526004601cfd5b345234f35b60207401000000000000000000000000000000000000000054345234f35b600160443573ffffffffffffffffffffffffffffffffffffffff6024351673ffffffffffffffffffffffffffffffffffffffff600435168233826020523452604034208054908134191461091c57828290810390811115610919576313be252b34526004601cfd5b81555b50505090918082549081039081111561093c5763f4d678b834526004601cfd5b813452825582540182557fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef602034a33452602034f35b60203460123452f35b6020346001600435337f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925602060246024358533602052345260403420868260245234602034604036013434637b04a2d060e01b966060604489604436036044604437345233600452525af16109f7576381cbe4db34526004601cfd5b5114610a0a576381cbe4db34526004601cfd5b55a33452f35b60207401000000000000000000000000000000000000000354345234f35b60207401000000000000000000000000000000000000000454345234f35b6002740100000000000000000000000000000000000000055410610a775763ab143c0634526004601cfd5b6002740100000000000000000000000000000000000000055574010000000000000000000000000000000000000002548060e01c306020604038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa610aea57633dd8248734526004601cfd5b3451306020602038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa610b2b57633dd8248734526004601cfd5b3451808460701c6dffffffffffffffffffffffffffff16946dffffffffffffffffffffffffffff169385858486929190936dffffffffffffffffffffffffffff85116dffffffffffffffffffffffffffff851115610b90576335278d1234526004601cfd5b15610ba2576335278d1234526004601cfd5b420363ffffffff16828282171715610cb7577401000000000000000000000000000000000000000454818284866e010000000000000000000000000000027bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1602740100000000000000000000000000000000000000035401740100000000000000000000000000000000000000035584846e010000000000000000000000000000027bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16020174010000000000000000000000000000000000000004555b50505081819060701b4260e01b1717740100000000000000000000000000000000000000025534526020527f1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1604034a184848490810390811115610d2257632a2ab27834526004601cfd5b9290810390811115610d3b57632a2ab27834526004601cfd5b92858574010000000000000000000000000000000000000001548015610f48578282028070ffffffffffffffffffffffffffffffffff1060071b81811c68ffffffffffffffffff1060061b1781811c64ffffffffff1060051b1781811c62ffffff1060041b1760b582821c62010000019160011c1b0260121c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c80910481119003818070ffffffffffffffffffffffffffffffffff1060071b81811c68ffffffffffffffffff1060061b1781811c64ffffffffff1060051b1781811c62ffffff1060041b1760b582821c62010000019160011c1b0260121c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8091048111900381811015610f455781818160050281019103740100000000000000000000000000000000000000005480158282029284928404141702610ec25763ad251c2734526004601cfd5b0460206060380360003960005190348183837401000000000000000000000000000000000000000054810190811015610f02576335278d1234526004601cfd5b74010000000000000000000000000000000000000000555401835552347fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef602034a35b50505b505050808202918183049115348218021814610f6b576335278d1234526004601cfd5b7401000000000000000000000000000000000000000183833452602052337f4c209b5fc8ad50758f13e2e1088ba56a560dff690a1c6fef26394f4c03821c4f604034a2557401000000000000000000000000000000000000000054806111165791808202918183049115348218021814610fec576335278d1234526004601cfd5b8070ffffffffffffffffffffffffffffffffff1060071b81811c68ffffffffffffffffff1060061b1781811c64ffffffffff1060051b1781811c62ffffff1060041b1760b582821c62010000019160011c1b0260121c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c809104811190036103e8810393506103e834903481838374010000000000000000000000000000000000000000548101908110156110b8576335278d1234526004601cfd5b74010000000000000000000000000000000000000000555401835552347fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef602034a36103e81061110f5763bb55fd2734526004601cfd5b5050611176565b9193929082908015828202928492840414170261113a5763ad251c2734526004601cfd5b04928015828202928492840414170261115a5763ad251c2734526004601cfd5b048181109082180218806111755763bb55fd2734526004601cfd5b5b803452600435903481838374010000000000000000000000000000000000000000548101908110156111af576335278d1234526004601cfd5b74010000000000000000000000000000000000000000555401835552347fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef602034a360017401000000000000000000000000000000000000000555602034f35b602060043554345234f35b60207401000000000000000000000000000000000000000154345234f35b7401000000000000000000000000000000000000000260027401000000000000000000000000000000000000000554106112795763ab143c0634526004601cfd5b60027401000000000000000000000000000000000000000555543054306020604038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa6112d457633dd8248734526004601cfd5b345190306020602038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa61131657633dd8248734526004601cfd5b34518360701c6dffffffffffffffffffffffffffff16846dffffffffffffffffffffffffffff166004359560e01c92828274010000000000000000000000000000000000000001548015611551578282028070ffffffffffffffffffffffffffffffffff1060071b81811c68ffffffffffffffffff1060061b1781811c64ffffffffff1060051b1781811c62ffffff1060041b1760b582821c62010000019160011c1b0260121c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c80910481119003818070ffffffffffffffffffffffffffffffffff1060071b81811c68ffffffffffffffffff1060061b1781811c64ffffffffff1060051b1781811c62ffffff1060041b1760b582821c62010000019160011c1b0260121c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c8082040160011c809104811190038181101561154e57818181600502810191037401000000000000000000000000000000000000000054801582820292849284041417026114cb5763ad251c2734526004601cfd5b046020606038036000396000519034818383740100000000000000000000000000000000000000005481019081101561150b576335278d1234526004601cfd5b74010000000000000000000000000000000000000000555401835552347fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef602034a35b50505b50505074010000000000000000000000000000000000000000548091868015828202928492840414170261158c5763ad251c2734526004601cfd5b049585801582820292849284041417026115ad5763ad251c2734526004601cfd5b04938585176115c35763749383ad34526004601cfd5b3034918034528181740100000000000000000000000000000000000000005403740100000000000000000000000000000000000000005554908103908111156116135763f4d678b834526004601cfd5b81557fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef602034a38486858860206040380360003960005191906fa9059cbb00000000000000000000000034526014526034523460446010346020945af1600134511417611687576390b8ec1834526004601cfd5b60206020380360003960005191906fa9059cbb00000000000000000000000034526014526034523460446010346020945af16001345114176116d0576390b8ec1834526004601cfd5b91306020604038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa61171057633dd8248734526004601cfd5b345191306020602038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa61175257633dd8248734526004601cfd5b3451938484929190936dffffffffffffffffffffffffffff85116dffffffffffffffffffffffffffff85111561178f576335278d1234526004601cfd5b156117a1576335278d1234526004601cfd5b420363ffffffff168282821717156118b6577401000000000000000000000000000000000000000454818284866e010000000000000000000000000000027bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1602740100000000000000000000000000000000000000035401740100000000000000000000000000000000000000035584846e010000000000000000000000000000027bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16020174010000000000000000000000000000000000000004555b50505081819060701b4260e01b1717740100000000000000000000000000000000000000025534526020527f1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1604034a1027401000000000000000000000000000000000000000155600174010000000000000000000000000000000000000005553452602052337f3e43e1de00e8a6bc1dfa3e950e6ade24c52e4a25de4dee7fb5affe918ad1e744604034a3604034f35b6b0b48554646535741502d563260203452602b52606034f35b60013473ffffffffffffffffffffffffffffffffffffffff60043516337fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef602034602435803354908103908111156119df5763f4d678b834526004601cfd5b33558086540186553452a352602034f35b600435806002740100000000000000000000000000000000000000055410611a1f5763ab143c0634526004601cfd5b600274010000000000000000000000000000000000000005557401000000000000000000000000000000000000000254806dffffffffffffffffffffffffffff169060701c6dffffffffffffffffffffffffffff16306020602038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa611ab357633dd8248734526004601cfd5b345191306020604038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa611af557633dd8248734526004601cfd5b345190810390811115611b0f576335278d1234526004601cfd5b9190810390811115611b28576335278d1234526004601cfd5b9260206040380360003960005191906fa9059cbb00000000000000000000000034526014526034523460446010346020945af1600134511417611b72576390b8ec1834526004601cfd5b60206020380360003960005191906fa9059cbb00000000000000000000000034526014526034523460446010346020945af1600134511417611bbb576390b8ec1834526004601cfd5b60017401000000000000000000000000000000000000000555005b602073ffffffffffffffffffffffffffffffffffffffff6024351673ffffffffffffffffffffffffffffffffffffffff6004351660443580338360205234526040342080549081341914611c4157828290810390811115611c3e576313be252b34526004601cfd5b81555b5050508282835450909180825490810390811115611c665763f4d678b834526004601cfd5b81604452825582540182557fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef60206044a390608060646388a7ca5c60e01b93602485346064360360646064375233600452525260203436606001343434955af1611cd7576385b1639434526004601cfd5b5114611cea576385b1639434526004601cfd5b6001345234f35b602060243560043560205234526040342054345234f35b6002740100000000000000000000000000000000000000055410611d335763ab143c0634526004601cfd5b600274010000000000000000000000000000000000000005557401000000000000000000000000000000000000000254806dffffffffffffffffffffffffffff16908060701c6dffffffffffffffffffffffffffff169060e01c91306020604038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa611dcd57633dd8248734526004601cfd5b345180611de15763bb55fd2734526004601cfd5b306020602038036000396000519060146f70a0823100000000000000000000000034525234602460106020935afa611e2057633dd8248734526004601cfd5b34519081611e355763bb55fd2734526004601cfd5b929190936dffffffffffffffffffffffffffff85116dffffffffffffffffffffffffffff851115611e6d576335278d1234526004601cfd5b15611e7f576335278d1234526004601cfd5b420363ffffffff16828282171715611f94577401000000000000000000000000000000000000000454818284866e010000000000000000000000000000027bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1602740100000000000000000000000000000000000000035401740100000000000000000000000000000000000000035584846e010000000000000000000000000000027bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16047bffffffffffffffffffffffffffffffffffffffffffffffffffffffff16020174010000000000000000000000000000000000000004555b50505081819060701b4260e01b1717740100000000000000000000000000000000000000025534526020527f1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1604034a160017401000000000000000000000000000000000000000555005b6103e83452602034f35b636fb1b0e96000526004601cfd",
            abi.encode(address(this), token0, token1)
        );
    }

    /// @dev Returns the total number of pairs.
    /// @return Total number of pairs.
    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    /**
     * @dev Creates a new pair with two tokens.
     * @param tokenA The address of the first token.
     * @param tokenB The address of the second token.
     * @return pair The address of the newly created pair.
     * @notice Tokens must be different and not already have a pair.
     */
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        // @dev sortTokens will revert if any address is 0 or address are identical
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        if (getPair[token0][token1] != address(0)) revert ErrPairExists(); // single check is sufficient

        bytes memory creationCode = getCreationCode(token0, token1);

        pair = CREATE3.deploy(keccak256(abi.encodePacked(token0, token1)), creationCode, 0);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /**
     * @dev Allows the owner to withdraw the entire balance of a specific token.
     * @param token The token to withdraw.
     * @param to The recipient address.
     */
    function withdraw(address token, address to) external onlyOwner {
        token.safeTransferAll(to);
    }

    /**
     * @dev Allows the owner to withdraw a specified amount of a specific token.
     * @param token The token to withdraw.
     * @param to The recipient address.
     * @param amount The amount of tokens to withdraw.
     */
    function withdraw(address token, address to, uint256 amount) external onlyOwner {
        token.safeTransfer(to, amount);
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        if (tokenA == tokenB) revert ErrIdenticalAddress();
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (token0 == address(0)) revert ErrZeroAddress();
    }
}
