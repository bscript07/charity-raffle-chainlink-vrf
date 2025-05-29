// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {CharityRaffle} from "../src/CharityRaffle.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();

        address owner = vm.envAddress("OWNER_ADDRESS");

        address proxy = Upgrades.deployTransparentProxy(
            "CharityRaffle.sol",
            owner,
            abi.encodeCall(
                CharityRaffle.initialize,
                (
                    owner,
                    0x70207125F31bCCE6179896768aD362510698E679,
                    112741710259463703515212115919949629435612283126873161761824155346931896741956,
                    0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                    0x750d86d38f206a5a0b86742ad7309a961207f461c4bfe35e989e3dae6bc5a87c
                )
            )
        );

        address implementation = Upgrades.getImplementationAddress(proxy);

        console.log("Proxy deployed to: ", proxy);
        console.log("Implementation deployed to: ", implementation);

        vm.stopBroadcast();
    }
}

// ---------------------------------------------------------------------------------------------//
// command for deploy and verify smart contracts on sepolia
// forge script script/deploy.s.sol:DeployScript --rpc-url sepolia --broadcast --verify -vv --private-key e4debeb368c6033a76f9319398e7f9db4750ce003ee4c01fdc2e14be3b019530
// forge verify-contract 0x4Aa118665275A6bCF4865F557677c241283ba6d4 ./src/CharityRaffle.sol:CharityRaffle --chain-id 11155111
