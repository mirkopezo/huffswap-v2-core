cat src/SWAP/template.huff                                        > src/SWAP/main.huff
balls src/SWAP/Update.balls -d                      | head -n -1 >> src/SWAP/main.huff
balls src/SWAP/GetReserves.balls -d                 | head -n -1 >> src/SWAP/main.huff


sed -i "s/\[_APPROVAL_EVENT_SIGNATURE\]/__EVENT_HASH(Approval)/g" src/SWAP/main.huff
sed -i "s/\[_TRANSFER_EVENT_SIGNATURE\]/__EVENT_HASH(Transfer)/g" src/SWAP/main.huff
sed -i "s/\[SIG_onTransferReceived\]/__FUNC_SIG(\"onTransferReceived(address,address,uint256,bytes)\")/g" src/SWAP/main.huff
sed -i "s/\[SIG_onApprovalReceived\]/__FUNC_SIG(\"onApprovalReceived(address,uint256,bytes)\")/g" src/SWAP/main.huff


# sanity check
huffc src/mocks/LPToken.huff

