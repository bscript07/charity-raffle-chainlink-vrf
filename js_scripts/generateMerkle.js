const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

// Charity participants addresses
const participants = [
    "0x8332be9B27b6b640010a305f9A85d374738E3042",
    "0x70207125F31bCCE6179896768aD362510698E679",
    "0xc3795f645056a68035D6C3Cb434B5545D2527952",
    "0x91039D4f74D751A96DB5c628b57D809cDa0ce927"
];

// Participant values
const values = participants.map((participant) => [participant]);

// Create Merkle Tree
const tree = StandardMerkleTree.of(values, ["address"]);

// Log merkle root
console.log("Merkle root: ", tree.root);

// Get proofs for each participant by searching tree entries
const participantsWithProof = participants.map((participant, idx) => {
    return {
        address: participant,
        proof: tree.getProof(idx)
    };
});


// Tree data
const data = {
    merkleRoot: tree.root,
    participants: participantsWithProof
}

// Save data in merkle_data.json
fs.writeFileSync("merkle_data.json", JSON.stringify(data));
console.log("✅ merkle_data.json saved!");