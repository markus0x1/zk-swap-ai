## Deploy

Run

### Deploy DEXs and Tokens 

```bash
forge script script/Deploy.s.sol:DeployMock --rpc-url gnosis --broadcast
```
### Deploy Plugin

```bash
forge script script/Deploy.s.sol:DeployPlugin --rpc-url gnosis --broadcast
```

### Deploy Safe

```bash
forge script script/Deploy.s.sol:DeploySafe --rpc-url gnosis --broadcast
```


## Deployments

### Gnosis Chain

#### Plugin

PLUGIN
`0x1f0d1D6C2077BC4dF72cC06C043e6Efd3dd86780`

VERIFIER
`0xB93487089afA862b9249bA637595d5c01ea8ece2`

#### Safe Protocol

REGISTRY_CONTRACT
`0xDecaE7fF9355417Ceb65603730527812E5b76Cb4`

SAFE_PROTOCOL_MANAGER
`0x1f6d70F4e71e95D68D61D89e6E13ed4091b980a5`

#### DEXs and Tokens

WETH_ADDRESS
`0x320ef4c3b08E55ba0836db61Ee90E0064e151e16`

DAI_ADDRESS
`0xb9B1a58F222bAD3f3ce57B1Ca2Bf6542D385464C`

DEX_A_ADDRESS
`0x3e07e4EaB2e1D43083ba8C097ac72a282bc506D6`

DEX_B_ADDRESS
`0x98D52889180a164b90e36C02a912eCFaC5E512F5`
